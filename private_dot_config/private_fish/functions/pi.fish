function pi --wraps pi -d "Run Pi with provider credentials loaded on demand"
    set -l model
    set -l model_follows 0
    for argument in $argv
        if test $model_follows -eq 1
            set model "$argument"
            set model_follows 0
            continue
        end
        switch "$argument"
            case --model -m
                set model_follows 1
            case '--model=*'
                set model (string replace -- '--model=' '' "$argument")
        end
    end

    __ensure_ai_secret_for_model "$model"; or return
    command pi $argv
end
