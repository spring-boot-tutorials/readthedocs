#! /bin/bash

rm -rf docs/build/html
sphinx-build -b html docs/source docs/build/html

ssh -i ~/.ssh/keys/aws-marcuschiu.pem ec2-user@www.marcuschiu.com << EOF
  rm -rf spring-boot-tutorials/
  mkdir spring-boot-tutorials
EOF

tar czf spring-boot-tutorials.tar.gz docs/build/html
scp -i ~/.ssh/keys/aws-marcuschiu.pem -r ./spring-boot-tutorials.tar.gz ec2-user@www.marcuschiu.com:~/spring-boot-tutorials
ssh -i ~/.ssh/keys/aws-marcuschiu.pem ec2-user@www.marcuschiu.com << EOF
  cd spring-boot-tutorials
  tar -xvzf spring-boot-tutorials.tar.gz
  rm spring-boot-tutorials.tar.gz
EOF
