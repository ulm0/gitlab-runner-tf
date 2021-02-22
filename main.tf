resource "tls_private_key" "runner_key" {
  count     = var.create_ssh_key ? 1 : 0
  algorithm = "RSA"
  rsa_bits  = "8192"
}

resource "aws_key_pair" "runner_key" {
  key_name   = format("ssh-key-ci-runner-%s", local.run_as_platform)
  public_key = local.public_key
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = [var.arch]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "runner" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.instance_type
  key_name                    = aws_key_pair.runner_key.key_name
  associate_public_ip_address = true

  tags = {
    Name = format("GitLab CI %s runner", local.run_as_platform)
  }
}

resource "null_resource" "bootstrap_runner" {
  depends_on = [tls_private_key.runner_key]
  triggers = {
    host        = aws_instance.runner.public_ip
    private_key = local.private_key
  }

  connection {
    type        = "ssh"
    host        = self.triggers.host
    user        = "ubuntu"
    private_key = self.triggers.private_key
  }

  provisioner "remote-exec" {
    inline = [
      file(format("%s/files/docker.sh", path.module)),
    ]
  }

  provisioner "file" {
    source      = format("%s/files/daemon.json", path.module)
    destination = "/home/ubuntu/daemon.json"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo mkdir -p /etc/docker",
      "sudo mv /home/ubuntu/daemon.json /etc/docker/daemon.json",
      "sudo chown 0:0 /etc/docker/daemon.json",
      "sudo chmod 0644 /etc/docker/daemon.json"
    ]
  }

  provisioner "remote-exec" {
    inline = [
      "sudo systemctl daemon-reload",
      "sudo systemctl restart docker"
    ]
  }

  provisioner "remote-exec" {
    inline = [
      templatefile(format("%s/files/runner.tpl", path.module), local.runner_params),
    ]
  }

  provisioner "remote-exec" {
    when = destroy
    inline = [
      "docker exec -it runner gitlab-runner unregister --all-runners",
    ]
  }
}
