# Test


1. Creacion de Infraestructura - Terraform 

https://github.com/jhonatanurbinat/retobase-java-2/tree/master/infraestructura/terraform

- Se creo una VPC ( podria fallar en su local si es que tiene el bloque ya utilizado )
- 2 subnets ( 2 publicas ) y 2 privadas
- Se creo roles para el instance profile ec2_ssm_role con acceso al system manager para debugear algun issue
- Se creo rol para la ejecucion ecs_execution_role
- Internet Gateway para exponer las subnets publicas
- Grupos de seguridad con ingresos y salidas amplios solo por ser ambiente de test
- Se creo un repositorio ECR privado donde se almacenaran las imagens compiladas desde el github action
- Se creo un cluster de ECS
- Launch Template y AutoScaling Group creados
- Load Balancer publico creado junto con los grupos de destino , listener , listener rule en puerto 80 
- se setea por defecto el task definition con una imagen publica con la misma aplicacion para despues actualizarlo con las compiladas desde el github actions desde el ECR privado
- se crea el ecs service y se auna al load balancer
- se crea gurpos de seguridad con reglas de entrada amplios para el service de ECS por motivos de debug

  

- 
  


