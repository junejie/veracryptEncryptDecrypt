install:
	#docker pull junejie/veracrypt:latest
	$(eval j_pwd := `pwd`)
	docker 
	docker run --name test-vera -d -v $(j_pwd):/data -it ub-veracrypt
	docker ps
	# docker stop test-vera
	# docker rm test-vera

