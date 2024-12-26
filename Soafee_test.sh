#!/bin/bash

docker login -u vayavyaaccountdockerhub -p vayavya-123 > /dev/null 2>&1
mkdir results
chmod 777 results

counter=1
video_files=("Video0" "Video1" "Video2" "Video3" "Video4")

for file_name in "${video_files[@]}"; do
	if [ $counter -eq 1 ]; then
 		#docker network rm soafee-network
   		docker network create --driver bridge soafee-network
     		((counter++))
       	fi
  	echo $PORT_1
   	echo $PORT_2
    	arch
	docker run -p 8089:8089 -p 5000:5000 --rm -e TEST_MODE=1 -v "$(pwd)"/results:/src/results --name=soafee_object_detector --network=soafee-network -dit vayavyaaccountdockerhub/soafee_object_detector_main:arm64
	docker run --name soafee_video_streamer -e TEST_MODE=1 --rm --network=soafee-network -v "$(pwd)"/Video_files/$file_name.mp4:/src/assets/Video0.mp4 -dit vayavyaaccountdockerhub/soafee_video_streamer_main:arm64
	sleep 5
 

	check_container_status() {
		local container_name=$1
		
		while true; do
			if ! docker ps --format "{{.Names}}" | grep -q "$container_name"; then
				echo "The $container_name container is no longer running."
				break
			fi
			sleep 1
		done
	}
	sleep 10
	check_container_status "soafee_video_streamer"
	sleep 5
	docker stop soafee_object_detector
	sleep 5
  	
	compare_text_files() {
 		
		local file1=$1
		local file2=$2
  		echo "File 1: $file1"
    		echo "File 2: $file2"
		
		lines1=$(head -n 50 "$file1")
  		echo "This is line 1 data"
    		echo $lines1
		lines2=$(head -n 50 "$file2")
  		echo "This is line 2 data"
  		echo $lines2
		if [ "$lines1" = "$lines2" ]; then
			echo "The files are the same."
		else
			echo "The files are different."
    			exit 1
  		fi
    	
	}
 	sleep 10
	arch=$(arch) 
  	if [ "$arch" == 'x86_64' ]; then 
		echo "X64 Architecture"
		compare_text_files ""$(pwd)"/results/Generated_ref.txt" ""$(pwd)"/Golden_ref_amd64/$file_name.txt"
 	elif [ "$arch" == 'aarch64' ]; then
    		echo "ARM Architecture"
      		compare_text_files ""$(pwd)"/results/Generated_ref.txt" ""$(pwd)"/Golden_ref_arm64/$file_name.txt"
      	fi
done

exit 0
