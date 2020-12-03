'use strict'
const AWS = require('aws-sdk');
AWS.config.update({ region: 'us-west-1' });

const getAll = async (ids) => {
  const db = new AWS.DynamoDB({ apiVersion: "2012-10-08" });
  let params = {
    TableName: 'devices',
  }

  let db_result = await db.scan(params).promise();
  let result = [];

  db_result.Items.forEach((item) => {
    console.log(item)
    if (ids.includes(item.id.S)) {
      result.push({
        id: item.id.S,
        level: item.level.BOOL,
        health: item.healthy.BOOL,
        battery: item.battery.N,
      });
    }
  });

  return {
    result,
  };
}

exports.handler = async (event) => {
  const results = await getAll(event);

  const response = {
    statusCode: 200,
    body: JSON.stringify(results),
  };
  return response;
};
