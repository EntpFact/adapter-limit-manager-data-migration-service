DELETE FROM hdfc_adapter_transformation_config WHERE api_id='LIMIT_MANAGER_INQUIRY_API|IMPS';

-- LIMIT-MANAGER-UPDATE API -----
DELETE FROM hdfc_adapter_transformation_config WHERE api_id='LIMIT_MANAGER_UPDATE_API|IMPS';
DELETE FROM hdfc_adapter_transformation_templates  WHERE transformation_template_id='limit-manager-update-api-template';
INSERT INTO hdfc_adapter_transformation_templates
(transformation_template_id, transformation_template_version, request_template,
response_template, message_type, created_on,
updated_on, created_by, updated_by, extension_fields,version,status)
VALUES('limit-manager-update-api-template', 1, '
let custID = [for (.debitDetails.partyDetailsList) .value if (.partyDetailType == "CUSTOMER_ID")]
let acctID = [for (.debitDetails.accountDetailsList) .value if (.accountDetailType == "ACNUM")]
{
  "sessionContext": {
    "channel": environmentVar("MESSAGE.CHANNEL"),
    "transactionBranch": environmentVar("MESSAGE.TRANSACTION_BRANCH"),
    "userId": environmentVar("MESSAGE.USER_ID"),
    "bankCode": environmentVar("MESSAGE.BANK_CODE"),
    "externalReferenceNo": .uniqueTransactionReferenceId
  },
  "TxnLimitupdateRequestDTO": {
    "requestString":
      {
        "channelId": .channel,
        "channelRefNo": .externalLogicalTransactionReferenceId,
        "switchRefNo": .uniqueTransactionReferenceId,
        "callerId": "EPH",
        "limitManagerRefNo": .originalLimitManagerReferenceId,
        "customerId": $custID[0],
        "accountId": $acctID[0],
        "isPartialReversal": .partialReversal,
        "reversalAmount": .creditResultDetailsList[0].amount.value,
        "originalTxnErrorCode": .creditResultDetailsList[0].errorCode,
        "originalTxnErrorDesc": .creditResultDetailsList[0].errorDescription,
        "status": .eventCode
      }

  }
}','
let externalReferenceNo = .status.externalReferenceNo
let limitManagerRefNo = .responseString.limitManagerRefNo
let txnStatus =.responseString.txnStatus
let errorCode = .responseString.errorCode
let erroDesc = .responseString.errorDescription
let switchRefNo = .responseString.requestEcho.switchRefNo
let creditLimitResponse = [
  {
    "serialNo": "1",
    "creditLimitReferenceId": $externalReferenceNo,
    "transactionStatus": $txnStatus,
    "errorCode": $errorCode,
    "errorDescription": $erroDesc
  }
]
{
  "uniqueTransactionReferenceId": $externalReferenceNo,
  "limitManagerReferenceId": $limitManagerRefNo,
  "transactionStatus": $txnStatus,
  "errorCode": $errorCode,
  "errorDescription": $erroDesc,
  "creditLimitResponseList": $creditLimitResponse,
  "originalUniqueTransactionReferenceId": $switchRefNo,
  "originalLimitManagerReferenceId": $limitManagerRefNo
}', 'JSON2JSON', current_timestamp, current_timestamp, 'ADMIN', 'ADMIN', NULL,0,'ACTIVE');

INSERT INTO hdfc_adapter_transformation_config
(api_id, transformation_template_id, transformation_template_version,
created_on, updated_on,  created_by, updated_by,
extension_fields,version,status )
VALUES('LIMIT_MANAGER_UPDATE_API|IMPS', 'limit-manager-update-api-template', 1,
current_timestamp,
current_timestamp, 'ADMIN', 'ADMIN',NULL,0,'ACTIVE');

-- FOR LIMIT-MANAGER-BLOCK API ----
DELETE FROM hdfc_adapter_transformation_config WHERE api_id='LIMIT_MANAGER_BLOCK_API|IMPS';
DELETE FROM hdfc_adapter_transformation_templates  WHERE transformation_template_id='limit-manager-block-api-template';
INSERT INTO hdfc_adapter_transformation_templates
(transformation_template_id, transformation_template_version, request_template,
response_template, message_type, created_on,
updated_on, created_by, updated_by, extension_fields,version,status)
VALUES('limit-manager-block-api-template', 1, '
let customerId = [for (.debitDetails.partyDetailsList) .value if (.partyDetailType == "CUSTOMER_ID")]
let merchantId = [for (.debitDetails.partyDetailsList) .value if (.partyDetailType == "MCC_CODE")]
let customerType = [for (.debitDetails.partyDetailsList) .value if (.partyDetailType == "CUSTOMER_TYPE")]
let accountNumber = [for (.debitDetails.accountDetailsList) .value if (.accountDetailType == "ACNUM")]
{
  "sessionContext": {
    "channel": environmentVar("MESSAGE.CHANNEL"),
    "transactionBranch": environmentVar("MESSAGE.TRANSACTION_BRANCH"),
    "userId": environmentVar("MESSAGE.USER_ID"),
    "bankCode": environmentVar("MESSAGE.BANK_CODE"),
    "externalReferenceNo": .uniqueTransactionReferenceId
  },
  "TxnLimitblockRequestDTO": {
    "requestString": {
      "channelId": .channel,
      "channelRefNo": .externalLogicalTransactionReferenceId,
      "switchRefNo": .uniqueTransactionReferenceId,
      "callerId": "EPH",
      "paymentNetwork": .creditDetailsList[0].networkType,
      "paymentType": .creditDetailsList[0].paymentMessageType,
      "paymentSubType": null,
      "customerId": $customerId[0],
      "accountId": $accountNumber[0],
      "paymentPriority": null,
      "amount": .creditDetailsList[0].amount.value,
      "merchantCode": $merchantId[0],
      "customerCategory": $customerType[0],
      "ethnicCode": null,
      "branchCode": .debitDetails.additionalAttributes.Cbs.Branch.Code
    }
  }
}', '
let externalReferenceNo = .status.externalReferenceNo
let limitManagerRefNo = .responseString.limitManagerRefNo
let txnStatus = .responseString.txnStatus
let errorCode = .responseString.errorCode
let errorDesc = .responseString.errorDescription
{
  "uniqueTransactionReferenceId" : $externalReferenceNo,
  "limitManagerReferenceId" : $limitManagerRefNo,
  "transactionStatus" : $txnStatus,
  "errorCode" : $errorCode,
  "errorDescription" : $errorDesc,
  "creditLimitResponseList" : [
    {
      "serialNo" : "1",
      "creditLimitReferenceId" : $limitManagerRefNo,
      "transactionStatus" : $txnStatus,
      "errorCode" : $errorCode,
      "errorDescription" : $errorDesc
    }
  ]
}', 'JSON2JSON', current_timestamp, current_timestamp, 'ADMIN', 'ADMIN', NULL,0,'ACTIVE');

INSERT INTO hdfc_adapter_transformation_config
(api_id, transformation_template_id, transformation_template_version,
created_on, updated_on,  created_by, updated_by,
extension_fields,version,status )
VALUES('LIMIT_MANAGER_BLOCK_API|IMPS', 'limit-manager-block-api-template', 1,
current_timestamp,
current_timestamp, 'ADMIN', 'ADMIN',NULL,0,'ACTIVE');