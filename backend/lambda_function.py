import json
import boto3

dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table('visitor-count')

def lambda_handler(event, context):
    # Obtener el contador actual
    response = table.get_item(Key={'id': 'visitante'})
    count = response['Item']['count']
    
    # Incrementar el valor
    new_count = count + 1
    
    # Guardar de nuevo
    table.put_item(Item={'id': 'visitante', 'count': new_count})
    
    return {
        'statusCode': 200,
        'body': json.dumps(new_count)
    }