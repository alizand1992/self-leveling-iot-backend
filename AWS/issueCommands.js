const AWS = require('aws-sdk');
const iotdata = new AWS.IotData({
  endpoint: 'REMOVED FOR SECURITY REASONS. PLEASE REPLACE WITH YOUR ENDPOINT',
  apiVersion: '2015-05-28',
});

exports.handler = async (event, context) => {
  const { id, command } = event;

  if (!id || !command) {
    return {
      statusCode: 400,
    };
  }

  const params = {
    'topic': 'command',
    'payload': JSON.stringify({
      'id': id,
      'command': command,
    }),
    qos: 1,
  };

  const result = await iotdata.publish(params).promise();
};
