docker manifest create \
registry.gitlab.com/ondabeta/ob-liquidsoap:latest \
--amend registry.gitlab.com/ondabeta/ob-liquidsoap:latest-arm64 \
--amend registry.gitlab.com/ondabeta/ob-liquidsoap:latest-amd64 

docker manifest push registry.gitlab.com/ondabeta/ob-liquidsoap:latest