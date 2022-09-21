resource "aws_ecs_cluster" "ecs_centos_cluster" {
  name = "ecs-centos-cluster"
}

resource "aws_ecs_service" "ecs_centos_service" {
  name            = "ecs-centos-service"
  cluster         = aws_ecs_cluster.ecs_centos_cluster.id
  task_definition = aws_ecs_task_definition.ecs_task.arn
  launch_type     = "FARGATE"
  desired_count   = 4

  network_configuration {
    subnets          = ["${aws_subnet.week19_ecs_publicsubnet1.id}", "${aws_subnet.week19_ecs_publicsubnet2.id}"]
    assign_public_ip = true
  }
}

resource "aws_ecs_task_definition" "ecs_task" {
  family                   = "ecs-task"
  container_definitions    = <<DEFINITION
    [
        {
            "name": "ecs-task",
            "image": "centos:latest",
            "essential": true,
            "cpu": 256,
            "memory": 512            
        }
    ]
DEFINITION
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  memory                   = 512
  cpu                      = 256
  execution_role_arn       = aws_iam_role.ecsTaskExecutionRole.arn
}

data "aws_iam_policy_document" "ecs-assume-role-policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ecsTaskExecutionRole" {
  name               = "ecsTaskExecutionRole"
  assume_role_policy = data.aws_iam_policy_document.ecs-assume-role-policy.json
}

resource "aws_iam_role_policy_attachment" "ecsTaskExecutionRole_Policy" {
  role       = aws_iam_role.ecsTaskExecutionRole.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}