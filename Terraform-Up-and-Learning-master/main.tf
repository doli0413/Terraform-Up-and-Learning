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

# Terraform 에서도 변수 선언이 가능하며, 입/출력 변수가 나뉜다!

# 입력 변수 : variable <NAME> {..}
variable "NAME" { # 블록 안에 변수의 메타데이터 기술
  # 입력 변수에는 3개의 매개변수를 입력, 전부 선택적 매개변수

  description = "변수를 설명하는 매개변수, plan & apply 명령 사용 시 변수를 설명해 줌!"

  //type = string
  //type = number
  //type = bool
  //type = list
  //type = set
  //type = map
  //type = list(string)
  //type = set(number)
  //type = map(bool)
  //type = map(any)
  //type = list(any)
  //type = set(any)
  //type = tuple([string])
  type = tuple([number,string,bool,map(string),list(any)])
  //type = object({
  //  name = string
  //  age = number
  //  tags = list(any)
  //  enabled = bool
  //})

  // 변수에 값이 주어지지않을 경우의 기본 값, object 타입의 경우, { .. } 코드 블록을 추가하여 기본 값 설정
  //default = {
  //  name = "soomin"
  //  age = 31
  //  tags = [1,7,"String",true]
  //  enabled = true
  //}

  default = ([31, "soomin", true, {key="value1"},[true,31,"test"]])

}
