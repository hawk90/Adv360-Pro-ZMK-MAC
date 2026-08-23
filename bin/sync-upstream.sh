#!/usr/bin/env bash
# Kinesis 업스트림 변경사항을 for_Mac / for_Windows 로 가져온다.
# 키맵 관련 파일(.gitattributes 의 merge=ours 목록)은 항상 우리 것을 유지한다.
set -euo pipefail

UPSTREAM_URL="https://github.com/KinesisCorporation/Adv360-Pro-ZMK.git"
UPSTREAM_BRANCH="V3.0"
TARGETS=(for_Mac for_Windows)

cd "$(git rev-parse --show-toplevel)"

if [ -n "$(git status --porcelain)" ]; then
  echo "작업 트리가 깨끗하지 않습니다. 커밋하거나 stash 후 다시 실행하세요." >&2
  exit 1
fi

git remote get-url upstream >/dev/null 2>&1 || git remote add upstream "$UPSTREAM_URL"
git config merge.ours.driver true

START_BRANCH="$(git rev-parse --abbrev-ref HEAD)"

echo "==> upstream fetch"
git fetch upstream "$UPSTREAM_BRANCH"

echo "==> $UPSTREAM_BRANCH 를 upstream 기준으로 fast-forward"
git checkout "$UPSTREAM_BRANCH"
git merge --ff-only "upstream/$UPSTREAM_BRANCH"

for b in "${TARGETS[@]}"; do
  echo "==> $b  <-  $UPSTREAM_BRANCH 머지"
  git checkout "$b"
  git merge --no-edit "$UPSTREAM_BRANCH"
done

git checkout "$START_BRANCH"

echo
echo "완료. 키맵 변경 여부 확인:"
echo "  git diff origin/for_Mac..for_Mac -- config/"
echo "문제 없으면 푸시:"
echo "  git push origin $UPSTREAM_BRANCH ${TARGETS[*]}"
