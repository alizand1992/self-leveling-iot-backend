'use strict'
const AWS = require('aws-sdk');
AWS.config.update({ region: 'us-west-1' });

const saveToDb = async ({ id, level, battery, healthy }) => {
  if (!id || (level === undefined && battery === undefined && healthy === undefined)) {
    return false;
  }

  const db = new AWS.DynamoDB({ apiVersion: "2012-10-08" });
  const updateExpressions = ["#TIME = :TIME"];

  const params = {
    TableName: 'devices',
    Key: {
      "id": {
        S: `${id}`,
      }
    },
    ExpressionAttributeNames: { "#TIME": "time" },
    ExpressionAttributeValues: {
      ":TIME": {
        S: `${new Date(Date.now())}`,
      }
    },
  };

  if (level !== undefined) {
    params.ExpressionAttributeNames = {
      ...params.ExpressionAttributeNames,
      "#LEVEL": "level",
    };

    params.ExpressionAttributeValues = {
      ...params.ExpressionAttributeValues,
      ":LEVEL": {
        BOOL: level,
      },
    };

    updateExpressions.push("#LEVEL = :LEVEL");
  }


  if (battery !== undefined) {
    params.ExpressionAttributeNames = {
      ...params.ExpressionAttributeNames,
      "#BATTERY": "battery",
    };

    params.ExpressionAttributeValues = {
      ...params.ExpressionAttributeValues,
      ":BATTERY": {
        N: battery,
      },
    };

    updateExpressions.push("#BATTERY = :BATTERY");
  }

  if (healthy !== undefined) {
    params.ExpressionAttributeNames = {
      ...params.ExpressionAttributeNames,
      "#HEALTHY": "healthy",
    };

    params.ExpressionAttributeValues = {
      ...params.ExpressionAttributeValues,
      ":HEALTHY": {
        BOOL: healthy,
      },
    };

    updateExpressions.push("#HEALTHY = :HEALTHY");
  }

  const updateExpression = "SET " + updateExpressions.join(", ");
  params.UpdateExpression = updateExpression;


  await db.updateItem(params).promise();

  return true;
}

exports.handler = async (event, context) => {
  const success = await saveToDb(event);
  const response = {
    statusCode: 200,
  };

  if (!success) {
    response.statusCode = 400;
  }

  return response;
};