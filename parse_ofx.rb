#!/usr/bin/env ruby

require 'ofx'
require 'awesome_print'

@in_file = ARGV[0]
begin
  raise ArgumentError.new("i need an ofx input file") if @in_file.nil?
  rescue ArgumentError => e
    STDERR.puts("[-][error:][#{e}]"); exit 1
end

in_file_handle = open(@in_file)
out_file_name = @in_file.gsub(/\.ofx$/,'.ru')

def parse__ofx(in_file_handle)
  o = OFX(in_file_handle)
  d = o.html.document
  sr = d.xpath("//stmtrs")

  output = []
  sr.each do |account|
    d = {}
    d[:account_id] = account.css("bankacctfrom acctid").text
    d[:account_type] = account.css("bankacctfrom accttype").text
    d[:statement_start] = account.css("banktranlist dtstart").text
    d[:statement_end] = account.css("banktranlist dtend").text
    d[:ledger_amount] = account.css("ledgerbal balamt").text
    d[:ledger_as_of] = account.css("ledgerbal dtasof").text
    d[:avialable_amount] = account.css("availbal balamt").text
    d[:available_as_of] = account.css("availbal dtasof").text
    d[:transactions] = []
    transactions = account.css("banktranlist stmttrn")
    transactions.each do |tx|
      tx_d = {}
      tx_d[:type] = tx.css("trntype").text
      tx_d[:posted] = tx.css("dtposted").text
      tx_d[:amount] = tx.css("trnamt").text
      tx_d[:fitid] = tx.css("fitid").text
      tx_d[:name] = tx.css("name").text if tx.css("trntype").text == "DEBIT"
      tx_d[:check_number] = tx.css("checknum").text if tx.css("trntype").text == "CHECK"
      tx_d[:memo] = tx.css("memo").text
      d[:transactions].push(tx_d)
    end
    output.push(d)
  end

  return output
end

result = parse__ofx(@in_file)
data = {}
data[:accounts] = result

STDERR.puts "[*][data:]"
STDERR.puts  data.ai

File.write(out_file_name,data)
STDERR.puts "[*][wrote ofx data as ruby hash to file:][#{out_file_name}]"
