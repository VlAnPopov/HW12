#!/bin/bash

checkmodule -M -m -o badNamed.mod /vagrant/badNamed.te
semodule_package -o badNamed.pp -m badNamed.mod
semodule -i badNamed.pp