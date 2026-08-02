#!/usr/bin/env bun

import type { Api, AssistantMessage, Context, Model, UserMessage } from "@earendil-works/pi-ai";
import { ModelRuntime } from "@earendil-works/pi-coding-agent";

type Role = "user" | "assistant";

interface Options {
  model: string;
  systemPrompt?: string;
  maxTokens: number;
  preview: boolean;
  messages: Array<{ role: Role; content: string }>;
  prompt: string;
}

function usage(): never {
  throw new Error(
    "usage: ai-one-shot --model provider/model [--system-prompt text] " +
      "[--max-tokens number] [--preview] [--message user|assistant text] -- prompt",
  );
}

function parseArgs(argv: string[]): Options {
  let model = "";
  let systemPrompt: string | undefined;
  let maxTokens = 384;
  let preview = false;
  const messages: Options["messages"] = [];
  let prompt = "";

  for (let index = 0; index < argv.length; index += 1) {
    const argument = argv[index];
    if (argument === "--") {
      prompt = argv.slice(index + 1).join(" ");
      break;
    }
    if (argument === "--preview") {
      preview = true;
      continue;
    }
    if (argument === "--model") {
      model = argv[++index] ?? usage();
      continue;
    }
    if (argument === "--system-prompt") {
      systemPrompt = argv[++index] ?? usage();
      continue;
    }
    if (argument === "--max-tokens") {
      const value = Number.parseInt(argv[++index] ?? "", 10);
      if (!Number.isSafeInteger(value) || value < 1) usage();
      maxTokens = value;
      continue;
    }
    if (argument === "--message") {
      const role = argv[++index] as Role | undefined;
      const content = argv[++index];
      if ((role !== "user" && role !== "assistant") || content === undefined) usage();
      messages.push({ role, content });
      continue;
    }
    usage();
  }

  if (!model || !prompt) usage();
  return { model, systemPrompt, maxTokens, preview, messages, prompt };
}

function textOf(message: AssistantMessage): string {
  return message.content
    .filter((part) => part.type === "text")
    .map((part) => part.text)
    .join("");
}

function historyMessage(
  message: Options["messages"][number],
  model: Model<Api>,
): UserMessage | AssistantMessage {
  if (message.role === "user") {
    return { role: "user", content: message.content, timestamp: Date.now() };
  }
  return {
    role: "assistant",
    content: [{ type: "text", text: message.content }],
    api: model.api,
    provider: model.provider,
    model: model.id,
    usage: {
      input: 0,
      output: 0,
      cacheRead: 0,
      cacheWrite: 0,
      totalTokens: 0,
      cost: { input: 0, output: 0, cacheRead: 0, cacheWrite: 0, total: 0 },
    },
    stopReason: "stop",
    timestamp: Date.now(),
  };
}

async function main(): Promise<void> {
  const options = parseArgs(process.argv.slice(2));
  const separator = options.model.indexOf("/");
  if (separator < 1 || separator === options.model.length - 1) usage();

  const provider = options.model.slice(0, separator);
  const modelId = options.model.slice(separator + 1);
  const runtime = await ModelRuntime.create({ allowModelNetwork: false });
  const model = runtime.getModel(provider, modelId);
  if (!model) throw new Error(`unknown model: ${options.model}`);

  const context: Context = {
    systemPrompt: options.systemPrompt,
    messages: [
      ...options.messages.map((message) => historyMessage(message, model)),
      { role: "user", content: options.prompt, timestamp: Date.now() },
    ],
    tools: [],
  };
  const requestOptions = { reasoning: "off" as const, maxTokens: options.maxTokens };

  let response: AssistantMessage;
  if (options.preview) {
    const stream = runtime.streamSimple(model, context, requestOptions);
    let wrotePreview = false;
    for await (const event of stream) {
      if (event.type === "text_delta") {
        process.stderr.write(event.delta);
        wrotePreview = true;
      }
    }
    response = await stream.result();
    if (wrotePreview) process.stderr.write("\n");
  } else {
    response = await runtime.completeSimple(model, context, requestOptions);
  }

  if (response.stopReason === "error" || response.stopReason === "aborted") {
    throw new Error(response.errorMessage ?? `model request ${response.stopReason}`);
  }
  process.stdout.write(textOf(response));
}

try {
  await main();
} catch (error) {
  const message = error instanceof Error ? error.message : String(error);
  process.stderr.write(`ai-one-shot: ${message}\n`);
  process.exitCode = 1;
}
