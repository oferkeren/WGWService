#!/bin/bash
RUN=$1
JANUS_WEB_SOCKET_SIGNALLING_PORT=443
JANUS_HTTP_ADMIN_PORT=7889

PORT_IS_OPEN=0
PORT_IS_CLOSED=1

#At setup:   /home/ec2-user/is_health.sh  -setup
#For test   /home/ec2-user/is_health.sh  -health first  /home/ec2-user/is_health.sh
EC2_INSTANCE_ID="$(wget -q -O - http://169.254.169.254/latest/meta-data/instance-id || terminate \"wget instance-id has failed: $?\")"
EC2_REGION=$(curl -s http://169.254.169.254/latest/dynamic/instance-identity/document | grep region | awk -F\" '{print $4}')

LOG_FILE=/home/ubuntu/logs/health_log.log
if [ -f "$LOG_FILE" ]; then
    echo "$LOG_FILE exists."
else 
    echo "$LOG_FILE does not exist. creating"
    touch $LOG_FILE
fi
function report {
      echo "[HealthCheckScript] - Status is unhealthy, reporting to AWS EC2 handler!" >>$LOG_FILE_PATH
      aws autoscaling set-instance-health --instance-id $EC2_INSTANCE_ID --region=$EC2_REGION --health-status Unhealthy
      #aws autoscaling set-instance-health --instance-id $EC2_INSTANCE_ID --region=$EC2_REGION  --health-status Healthy
}
function health {
      echo "$RUN"

      echo "start of health function"

      JANUS_PID=$(pgrep -f janus)
      JANUS_FD=$(lsof -p $JANUS_PID | wc -l)
      echo "JANUS_FD:"$JANUS_FD >>$LOG_FILE

      JANUS_MEM=$(pmap $JANUS_PID | tail -n 1)
      echo "JANUS_MEM:"$JANUS_MEM >>$LOG_FILE

      JANUS_ALL_THREADS_NUMBER=$(ps -To pcpu,tid,comm -C janus | sort -r -k1 | wc -l)
      echo "JANUS_ALL_THREADS_NUMBER:"$JANUS_ALL_THREADS_NUMBER >>$LOG_FILE

      JANUS_ALL_MEDIA_THREADS_NUMBER=$(ps -To pcpu,tid,comm -C janus | sort -r -k1 | grep gst | wc -l)
      echo "JANUS_ALL_MEDIA_THREADS_NUMBER:"$JANUS_ALL_MEDIA_THREADS_NUMBER >>$LOG_FILE

      JANUS_VIDEO_THREADS_NUMBER=$(ps -To pcpu,tid,comm -C janus | sort -r -k1 | grep gstVideo | wc -l)
      echo "JANUS_VIDEO_THREADS_NUMBER:"$JANUS_VIDEO_THREADS_NUMBER >>$LOG_FILE

      JANUS_AUDIO_INGRESS_THREADS_NUMBER=$(ps -To pcpu,tid,comm -C janus | sort -r -k1 | grep gstAudioIngress | wc -l)
      echo "JANUS_AUDIO_INGRESS_THREADS_NUMBER:"$JANUS_AUDIO_INGRESS_THREADS_NUMBER >>$LOG_FILE

      JANUS_AUDIO_EGRESS_THREADS_NUMBER=$(ps -To pcpu,tid,comm -C janus | sort -r -k1 | grep gstAudioEgress | wc -l)
      echo "JANUS_AUDIO_EGRESS_THREADS_NUMBER:"$JANUS_AUDIO_EGRESS_THREADS_NUMBER >>$LOG_FILE

      JANUS_AUDIO_MIXER_THREADS_NUMBER=$(ps -To pcpu,tid,comm -C janus | sort -r -k1 | grep gstAudioMixer | wc -l)
      echo "JANUS_AUDIO_MIXER_THREADS_NUMBER:"$JANUS_AUDIO_MIXER_THREADS_NUMBER >>$LOG_FILE

      if [ "$RUN" == "first" ]; then
            JANUS_APP_IS_RUNNING_STATUS=$(ps aux | pgrep janus | wc -l)
            JANUS_WEB_SOCKET_SIGNALLING_PORT_STATUS=$(
                  nc -zv localhost ${JANUS_WEB_SOCKET_SIGNALLING_PORT} &>/dev/null
                  echo $?
            )
            JANUS_HTTP_ADMIN_PORT_STATUS=$(
                  nc -zv localhost ${JANUS_HTTP_ADMIN_PORT} &>/dev/null
                  echo $?
            )

            echo "RUN:-----1---- "
            if [ "$JANUS_APP_IS_RUNNING_STATUS" == "0" ]; then
                  echo "Janus app is not running!" >>$LOG_FILE
                  cd /home/ubuntu/WGWService
                  gdb -q -n -ex bt -batch janus core >>$LOG_FILE 2>&1
                  "$FILEPATH" -health second "$FILEPATH" &
                  exit
            elif [ "$JANUS_WEB_SOCKET_SIGNALLING_PORT_STATUS" == "$PORT_IS_CLOSED" ]; then
                  echo "Janus port=${JANUS_WEB_SOCKET_SIGNALLING_PORT} is not listening!" >>$LOG_FILE_PATH
                  "$FILEPATH" -health second "$FILEPATH" &
                  exit
            elif [ "$JANUS_HTTP_ADMIN_PORT_STATUS" == "$PORT_IS_CLOSED" ]; then
                  echo "Janus port=${JANUS_HTTP_ADMIN_PORT} is not listening!" >>$LOG_FILE
                  "$FILEPATH" -health second "$FILEPATH" &
                  exit
            else
                  echo "First Test..PASS"
                  exit
            fi

      elif [ "$RUN" == 'second' ]; then
            echo "RUN-----2----Sleep 10s "
            sleep 10
            JANUS_APP_IS_RUNNING_STATUS=$(ps aux | pgrep janus | wc -l)
            JANUS_WEB_SOCKET_SIGNALLING_PORT_STATUS=$(
                  nc -zv localhost ${JANUS_WEB_SOCKET_SIGNALLING_PORT} &>/dev/null
                  echo $?
            )
            JANUS_HTTP_ADMIN_PORT_STATUS=$(
                  nc -zv localhost ${JANUS_HTTP_ADMIN_PORT} &>/dev/null
                  echo $?
            )
            if [ "$JANUS_APP_IS_RUNNING_STATUS" == "0" ]; then
                  echo "Janus app is not running!" >>$LOG_FILE
                  report
            elif [ "$JANUS_WEB_SOCKET_SIGNALLING_PORT_STATUS" == "$PORT_IS_CLOSED" ]; then
                  echo "Janus port=${JANUS_WEB_SOCKET_SIGNALLING_PORT} is not listening!" >>$LOG_FILE
                  report
            elif [ "$JANUS_HTTP_ADMIN_PORT_STATUS" == "$PORT_IS_CLOSED" ]; then
                  echo "Janus port=${JANUS_HTTP_ADMIN_PORT} is not listening!" >>$LOG_FILE
                  report
            else
                  echo "Second Test..PASS"
                  exit
            fi

      fi
      exit
}

echo "$(date) with user $(whoami) running health script"
health
