###############################################################################
#
# The MIT License (MIT)
#
# Copyright (c) Crossbar.io Technologies GmbH
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
#
###############################################################################


# https://www.terraform.io/docs/providers/aws/r/launch_configuration.html
resource "aws_launch_configuration" "launchconfig1" {
    name_prefix     = "launchconfig1"
    image_id        = var.AMIS[var.AWS_REGION]
    instance_type   = "t3a.medium"

    key_name        = aws_key_pair.keypair1.key_name
    security_groups = [aws_security_group.myinstance.id]

    user_data       = templatefile("files/setup-edge.sh", {
            file_system_id = aws_efs_file_system.efs1.id,
            access_point_id_home = aws_efs_access_point.efs-home.id
            master_url = "ws://${aws_instance.master.private_ip}:9000/ws"
            master_hostname = aws_instance.master.private_ip
            master_port = 9000
        }
    )
}

# https://www.terraform.io/docs/providers/aws/r/autoscaling_group.html
resource "aws_autoscaling_group" "autoscaling1" {
    name                      = "autoscaling1"
    launch_configuration      = aws_launch_configuration.launchconfig1.name

    vpc_zone_identifier       = [aws_subnet.vpc1-public-1.id, aws_subnet.vpc1-public-2.id, aws_subnet.vpc1-public-3.id]
    load_balancers            = [aws_elb.elb1.name]

    min_size                  = 2
    max_size                  = 2
    health_check_grace_period = 300
    health_check_type         = "EC2"

    tag {
        key                 = "Name"
        value               = "Crossbar.io FX (Edge)"
        propagate_at_launch = true
    }
    tag {
        key                 = "node"
        value               = "edge"
        propagate_at_launch = true
    }
    tag {
        key                 = "env"
        value               = "prod"
        propagate_at_launch = true
    }
}
