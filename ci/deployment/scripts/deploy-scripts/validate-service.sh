for i in {0..300}
do
        # SANITY_HEALTH_CHECK_TOKEN="$(. $(dirname $0)/aws/get-sanity-health-check-token.sh)"
        # SANITY_HEALTH_CHECK="curl -s -o /dev/null -w %{http_code} -X GET http://localhost/WGW/External-Services/SanityHealthCheck?credentials=$SANITY_HEALTH_CHECK_TOKEN"

        # sanityHealthCheckResult="200"
        # if [ "$sanityHealthCheckResult" -ne "200" ]; then
                # sleep 1
        # else
                # echo "SanityHealthCheck succeeded!"
                healthCheckResult=$(wget -nv --spider --server-response --no-check-certificate https://localhost:7889/admin 2>&1 |  awk '/^  HTTP/{print $2}')
                if [ "$healthCheckResult" -eq "200" ]; then
                      echo "succeeded"
                      exit 0
                else
                      sleep 1
                fi
        # fi
done

exit 1