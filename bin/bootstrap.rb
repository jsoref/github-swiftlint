#!/usr/bin/env ruby

$LOAD_PATH.unshift File.expand_path("../../sources", __FILE__)
$LOAD_PATH.unshift File.expand_path("../../vendor", __FILE__)

require 'webhook/listener'
Webhook::Listener.run
