locals {
  # quite ugly
  arm_instances = [
    "a1.medium",
  ]
  ami = coalesce(
    var.ami,
    contains(local.arm_instances, var.instance_type) ? data.aws_ami.ubuntu_arm.id: null,
    # contains(local.arm_instances, var.instance_type) ? data.aws_ami.al2.id: null,
    data.aws_ami.ubuntu.id
  )
}

resource "aws_instance" "this" {
  ami           = local.ami
  instance_type = var.instance_type
  user_data     = var.user_data
  key_name      = var.key_name
  subnet_id     = var.subnet_id
  private_ip    = var.private_ip

  iam_instance_profile = var.iam_instance_profile

  vpc_security_group_ids = var.vpc_security_group_ids
  source_dest_check      = var.source_dest_check

  monitoring = var.monitoring

  lifecycle { ignore_changes = [ ami ] }
  tags = merge(
    {
      Name = var.name
    },
    var.tags,
  )
}

resource "aws_eip" "this" {
  count = var.associate_public_ip ? 1 : 0
  instance = aws_instance.this.id
}
