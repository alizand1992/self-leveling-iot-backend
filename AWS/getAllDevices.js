'use strict'
const AWS = require('aws-sdk');
AWS.config.update({ region: 'us-west-1' });

const getDevices = async () => {
  const db = new AWS.DynamoDB({ apiVersion: "2012-10-08" });
  let params = {
    TableName: 'devices',
  }

  let db_result = await db.scan(params).promise();
  let result = [];

  db_result.Items.forEach((item) => {
    result.push(item);
  });

  return result;
}

exports.handler = async (event) => {
    const devices = await getDevices();

    const response = {
        statusCode: 200,
        body: JSON.stringify(devices),
    };

    return response;
};
