
resource "aws_key_pair" "name" {
  public_key = "APP-DEV.pem"
}
resource "aws_instance" "ec2" {
  ami = var.ami_id
  associate_public_ip_address = var.associate_public_ip_address
  availability_zone = var.availability_zone
  subnet_id = var.subnet_id
  instance_type = var.instance_type
  key_name = var.key_name
  vpc_security_group_ids = var.vpc_security_group_ids

  connection {
    host = self.public_ip
    user = "ec2-user" #change the user name baed on the os
    private_key = aws_key_pair.name

  }
  ebs_block_device {
    device_name = "/dev/sda1"
    delete_on_termination = true
    encrypted = true
    volume_size = 20
  }
  provisioner "remote-exec" {
    inline = [ 
      "sudo mkdir /opt/test"
     ]
  }

}
