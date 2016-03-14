#!/usr/bin/zsh

source $XDG_CONFIG_HOME/secure/vars.zsh

function() {

local account_number=$CHASE_ACCOUNT_NUM
local app_id='QMOFX'
local app_version=1900
local credit_card_number=$CHASE_CC_NUM
local fid=10898
local now=$(date '+%Y%m%d%H%M%S.000[0:GMT]')
local org='B1'
local uri='https://ofx.chase.com'
local user_id=$CHASE_USER_ID
local user_password=$CHASE_USER_PASSWORD

local dtacctup=$account_number

local trn_uid=$(echo "${now}${uri}${user_name}" | md5sum | cut -f 1 -d ' ')

local ofx_headers=$(cat <<EOD
OFXHEADER:100
DATA:OFXSGML
VERSION:102
SECURITY:NONE
ENCODING:USASCII
CHARSET:UTF-8
COMPRESSION:NONE
OLDFILEUID:NONE
NEWFILEUID:NONE

EOD

)

local signon=$(cat <<EOD

<SIGNONMSGSRQV1>
  <SONRQ>
    <DTCLIENT>${now}</DTCLIENT>
    <USERID>${user_id}</USERID>
    <USERPASS>${user_password}</USERPASS>
    <GENUSERKEY>N</GENUSERKEY>
    <LANGUAGE>ENG</LANGUAGE>

    <FI>
      <ORG>${org}</ORG>
      <FID>${fid}</FID>
    </FI>

    <APPID>${app_id}</APPID>
    <APPVER>${app_version}</APPVER>
  </SONRQ>
</SIGNONMSGSRQV1>

EOD

)

local account_info=$(cat <<EOD

<SIGNUPMSGSRQV1>
  <ACCTINFOTRNRQ>
    <TRNUID>${trn_uid}</TRNUID>
    <ACCTINFORQ>
      <DTACCTUP>${dtacctup}</DTACCTUP>
    </ACCTINFORQ>
  </ACCTINFOTRNRQ>
</SIGNUPMSGSRQV1>

EOD

)

local payee=520449050 # Credit card

# NOTE: Gives a not authorizied error

local add_payee=$(cat <<EOD

<BILLPAYMSGSRQV1>
	<PAYEETRNRQ>
		<TRNUID>127677</TRNUID>
		<PAYEERQ>
			<PAYEE>
				<NAME>ACME Rocket Works</NAME>
				<ADDR1>101 Spring St.</ADDR1>
				<ADDR2>Suite 503</ADDR2>
				<CITY>Watkins Glen</CITY>
				<STATE>NY</STATE>
				<POSTALCODE>12345-6789</POSTALCODE>
				<PHONE>888.555.1212</PHONE>
			</PAYEE>
			<PAYACCT>1001-99-8876</PAYACCT>
		</PAYEERQ>
	</PAYEETRNRQ>
</BILLPAYMSGSRQV1>

EOD

)

local billpay=$(cat <<EOD

<BILLPAYMSGSRQV1>
	<PMTTRNRQ>
    <TRNUID>${trn_uid}</TRNUID>

		<PMTRQ> 
			<PMTINFO> 
				<BANKACCTFROM>
					<BANKID>272479935</BANKID>
					<ACCTID>6225493</ACCTID>
					<ACCTTYPE>CHECKING</ACCTTYPE>
				</BANKACCTFROM>
				<TRNAMT>10.00</TRNAMT>
				<PAYEEID>${payee}
				<PAYACCT>10101</PAYACCT>
				<DTDUE>20151108</DTDUE>
				<MEMO>testing</MEMO>
			</PMTINFO>
		</PMTRQ>
	</PMTTRNRQ>
</BILLPAYMSGSRQV1>

EOD

)

local start_date='201508010000'
local end_date=$(date '+%Y%m%d%H%M%S')

local credit_card_statement=$(cat <<EOD

<CREDITCARDMSGSRQV1>
  <CCSTMTTRNRQ>
    <TRNUID>${trn_uid}
    <CCSTMTRQ>
      <CCACCTFROM>
        <ACCTID>${credit_card_number}
      </CCACCTFROM>
      <INCTRAN>
        <DTSTART>${start_date} 
        <DTEND>${end_date}
        <INCLUDE>Y
      </INCTRAN>
    </CCSTMTRQ>
  </CCSTMTTRNRQ>
</CREDITCARDMSGSRQV1>

EOD

)

# local data=$(cat <<EOD
# ${ofx_headers}

# <OFX>
# ${signon}
# ${account_info}
# </OFX>

# EOD

# )

local credit_card_statement=$(cat <<EOD

<CREDITCARDMSGSRQV1>
  <CCSTMTTRNRQ>
    <TRNUID>${trn_uid}
    <CCSTMTRQ>
      <CCACCTFROM>
        <ACCTID>${credit_card_number}
      </CCACCTFROM>
      <INCTRAN>
        <DTSTART>${start_date} 
        <DTEND>${end_date}
        <INCLUDE>Y
      </INCTRAN>
    </CCSTMTRQ>
  </CCSTMTTRNRQ>
</CREDITCARDMSGSRQV1>

EOD

)

# ${credit_card_statement}

local data=$(cat <<EOD
${ofx_headers}

<OFX>
${signon}
${credit_card_statement}
</OFX>

EOD

)

headers=(

-H 'Content-Type: application/x-oFX'

)

curl_options=(

"${headers[@]}"
--data-binary "${data}"
-X 'POST'
-s

)

# echo $curl_options

# Debug
# local response=$(curl --trace - -D- "${curl_options[@]}" "${uri}")
# echo $response
# return

local split_lines='s/</\n</g'
local fix_stupid_xml='s/^<\([A-Z0-9]\+\)>\(.\+\)$/<\1>\2<\/\1>/g'

local response=$(curl "${curl_options[@]}" "${uri}")

response=$(echo $response | sed -e "${split_lines}")

response=$(echo $response | tail -n+12)

response=$(echo $response | sed -e "${fix_stupid_xml}")

response=$(echo $response | xmllint --format -)

response=$(echo $response | xml-json 'OFX')

response=$(echo $response | underscore print --outfmt text)

# response=$(echo $response | underscore extract CREDITCARDMSGSRSV1)

# response=$(echo $response | underscore extract CCSTMTTRNRS)

# response=$(echo $response | underscore extract CCSTMTRS)

# response=$(echo $response | underscore extract BANKTRANLIST)

# response=$(echo $response | underscore extract STMTTRN)

# response=$(echo $response | underscore pluck TRNAMT)

echo "${response}" | underscore print --outfmt pretty | less

}

