import json
import boto3
import logging

# Configurar logs para depuración en CloudWatch
logger = logging.getLogger()
logger.setLevel(logging.INFO)

dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table('visitor-count')

def lambda_handler(event, context):
    try:
        # Intentar obtener el contador actual
        response = table.get_item(Key={'id': 'visitante'})
        
        # Si el ítem no existe, empezamos en 0
        if 'Item' in response:
            count = int(response['Item']['count'])
        else:
            count = 0
            
        # Incrementar
        new_count = count + 1
        
        # Guardar el nuevo valor
        table.put_item(Item={'id': 'visitante', 'count': new_count})
        
        logger.info(f"Nuevo conteo: {new_count}")
        
        return {
            'statusCode': 200,
            'headers': {
                'Access-Control-Allow-Origin': '*', # Necesario para que el navegador acepte la respuesta
                'Content-Type': 'application/json'
            },
            'body': json.dumps(new_count)
        }
        
    except Exception as e:
        logger.error(f"Error procesando contador: {str(e)}")
        return {
            'statusCode': 500,
            'body': json.dumps({'error': 'No se pudo actualizar el contador'})
        }