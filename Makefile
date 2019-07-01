
hello:
	echo "Hello, MaxScale!"

create:
	cd m1 && vagrant up && cd ..
	cd m2 && vagrant up && cd ..

destroy:
	cd m1 && vagrant destroy -f && cd ..
	cd m2 && vagrant destroy -f && cd ..
