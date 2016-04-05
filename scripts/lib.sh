#!/bin/bash

function timestamp()
{
  format=$1
  : ${format:='+%Y%m%d-%H%M'}
  echo `date ${format}`
}
