#!/usr/bin/env bash
# 安装 skillcrate 里的 skill。
#   ./install.sh              # 全装
#   ./install.sh geeklens     # 只装一个
set -euo pipefail

ALL=(calm-explain geeklens project-memory host-memory file-conversion-toolkit)
TARGETS=("$@")
[ ${#TARGETS[@]} -eq 0 ] && TARGETS=("${ALL[@]}")

for s in "${TARGETS[@]}"; do
    case " ${ALL[*]} " in
        *" $s "*) ;;
        *) echo "unknown skill: $s (known: ${ALL[*]})" >&2; exit 1 ;;
    esac
    echo "> $s"
    npx --yes skills add wurenrumian/skillcrate --global --skill "$s" --yes
done

echo "done. 更新用 'npx skills update -g -y'。"
