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


# https://www.terraform.io/docs/providers/aws/r/instance.html
resource "aws_instance" "master" {
    ami = var.AMIS[var.AWS_REGION]
    instance_type = "t3a.medium"

    subnet_id = aws_subnet.vpc1-master.id
    vpc_security_group_ids = [aws_security_group.master.id]

    key_name = aws_key_pair.keypair1.key_name

    tags = {
        Name = "Crossbar.io FX (Master)"
        node = "master"
        env = "prod"
    }

    user_data = templatefile("files/setup-master.sh", {
            file_system_id = aws_efs_file_system.efs1.id,
            access_point_id_home = aws_efs_access_point.efs-home.id
            access_point_id_master = aws_efs_access_point.efs-master.id
            master_port = 9000
        }
    )
}
