provider "aws" {
  region = "ap-northeast-2"
}

resource "aws_instance" "example" {
  ami = "ami-04341a215040f91bb" // AWS Locator , Ubuntu 20.04
  instance_type = "t2.micro" // EC2 Type

  tags = { // tags
    Name = "terraform-example"
  }

  # user_data : AWS EC2 구동 시 실행하는 스크립트
  # Linux Heredoc 문법
  user_data = <<-EOF
                #!/bin/bash
                echo "Hello World" 1>index.html
                nohup busybox httpd -f -p 8080 &
                EOF

  # security_group 을 EC2에 바인딩해야 함 : vpc_security_group_ids []
  vpc_security_group_ids = [aws_security_group.instance.id] # instance 보안 그룹 생성 시 return 되는 id 식별값 참조
  # aws_instance.example 이 aws_security_group.instance 의 id 속성 값을 참조.
  # aws_instance.example 이 aws_security_group.instance 에 의존하고 있음
}

// 테라폼 코드에 의존관계가 있을 시 프로세스
// 1. 테라폼이 HCL 코드를 분석하여 종속 관계를 분석
// 2. 테라폼이 종속성 그래프를 작성
// 3. 테라폼이 종속성 그래프에 따라 자원 생성 순서를 결정하게 됨!
# 보안 그룹 : security_group
resource "aws_security_group" "instance" {
  name = "terraform-example-instance"

  # 수신 정책 : Ingress
  ingress {
    # 포트 범위 from ~ to
    from_port = 8080
    to_port = 8080
    # 프로토콜
    protocol = "tcp"
    # 접근 아이피 대역
    cidr_blocks = ["0.0.0.0/0"]
  }
}