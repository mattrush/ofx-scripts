#!/usr/bin/env ruby

# LIBS

require_relative './common.rb'
require 'pry'
require 'date'
require 'open3'
require 'awesome_print'

# PARAMS

time_period = ARGV[0]
begin
  raise ArgumentError.new("i need a time period") if time_period.nil?
  rescue ArgumentError => e
    STDERR.puts("[-][error:][#{e}]"); exit 1
end

# DATA

verbose = true
last_updated_file = "last_updated.txt"
last_updated_date = `tail -n 1 #{last_updated_file}`
pass__path_to_password = "test/pw"                    # SET THIS 
pass__path_to_account_number = "test/account_number"  # SET THIS
pass__path_to_fi_short_name = "test/short_name"       # SET THIS

STDERR.puts("last_updated_date: #{last_updated_date}")

today_date = Date.today.strftime("%Y%m%d")

cmd = "pass show #{pass__path_to_account_number}"
account_number = run_local(cmd).first

cmd = "pass show #{pass__path_to_password}"
account_password = run_local(cmd).first

cmd = "pass show #{pass__path_to_fi_short_name}"
fi_short_name = run_local(cmd).first

STDERR.puts("[*][account_number: #{account_number}")
STDERR.puts("[*][fi_short_name: #{fi_short_name}")

# FUNCS

def timestamp()
  Time.now.to_i
end

def get_start_and_end_dates(time_period,verbose=false) # string of 'last_month' or 'this_month' as time_period. returns [start_date,end_date]
  today_datetime = DateTime.now()
  today_date = today_datetime.strftime("%Y%m%d")
  current_year = today_datetime.year
  current_month = today_datetime.month
  current_day = today_datetime.day
  last_month = current_month - 1
  last_day_of_last_month = Date.new(current_year,last_month,-1).strftime("%Y%m%d")
  first_day_of_last_month = Date.new(current_year,last_month,1).strftime("%Y%m%d")
  first_day_of_this_month = Date.new(current_year,current_month,1).strftime("%Y%m%d")
  case time_period
    when "last_month" then
      start_date = first_day_of_last_month
      end_date = last_day_of_last_month
    when "this_month" then
      start_date = first_day_of_this_month
      end_date = today_date
    else
      STDERR.puts "error: invalid option." if verbose
      STDERR.puts "valid option: last_month | this_month" if verbose
      return [nil,nil]
  end
  if verbose
    STDERR.puts "[*][today_datetime:][#{today_datetime}]"
    STDERR.puts "[*][today_date:][#{today_date}]"
    STDERR.puts "[*][first_day_of_this_month:][#{first_day_of_this_month}]"
    STDERR.puts "[*][last_day_of_last_month:][#{last_day_of_last_month}]"
    STDERR.puts "[*][first_day_of_last_month:][#{first_day_of_last_month}]"
    STDERR.puts "[>][time_period:][#{time_period}]"
    STDERR.puts "[+][start_date:][#{start_date}]"
    STDERR.puts "[+][end_date:][#{end_date}]"
  end
  return [start_date,end_date]
end

# RC

start_date, end_date = get_start_and_end_dates(time_period,verbose)

ts = timestamp()
output_file = "./data/statement.all.#{start_date}-#{end_date}.#{ts}.ofx"

cmd = "
ofxget stmt #{fi_short_name} \
  --all \
  --password #{account_password} \
  --start #{start_date} \
  --end #{end_date} \
    > #{output_file}
"
STDERR.puts(cmd) if verbose

response = run_local(cmd)

if response
  File.open(last_updated_file,'a') do |f|
    f.puts(today_date)
  end
end

STDERR.puts(response)
STDERR.puts(response.class)
