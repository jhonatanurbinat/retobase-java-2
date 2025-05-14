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

2.  Codigo SRC

https://github.com/jhonatanurbinat/retobase-java-2/blob/master/src/main/java/arcmop/blog/springbootest/controladores/ControladorHolaMundo.java

- el endpoint con el que se crea el [DNSLOADBalancer]/sumar/1/2
- probar agregando nuevos endpoints y corriendo el pipeline de githubactions denuevo para ver la actualizacion del endpoint al finalizar
  demora como maximo 5 minutos para refrescar el endpoint
- No actualizar el endpoint /sumar modificando su implementacion ya que hay una prueba en https://github.com/jhonatanurbinat/retobase-java-2/blob/master/src/test/java/arcmop/blog/springbootest/controladores/ControladorHolaMundoUTTest.java  que hace que si no se cumpla se rompe el build
- los endpoints es sumar/param1/param2 ej sumar/1/2 lo mismo con restar  podria haber alguna discrepacincia ya que al inicializar el ecs uso primero la imagen de docker hub jhonatanurbinat/reto pero ya cuando se corre el pipeline se usa la imagen hecha desde el pipeline

3. Automatizacion

   https://github.com/jhonatanurbinat/retobase-java-2/blob/master/.github/workflows/maven-publish.yml

   se hace la compilacion del contenedor se crea la imagen se pushea al ecr privado y se actualiza el endpoint en el ECS y se puede visualizar en el load balancer despues de 3 maximo 5 minutos
   probar con DNSLOADBLANACER/sumar/1/2 o si no con el endpoint que agrego anteriormente en el archivo de ControladorHolaMundo.java
 de Codigo SRC

  se usan algunso secrets propios de la cuenta que se uso y algunas variables estan estaticas por temas de testing

  Cualquier duda hacer ellegar algu nerror 

  Alguanas Evidencias

 DNS LoadBalancer publico
  ![image](https://github.com/user-attachments/assets/185b26da-6b21-40e9-a3cd-23def602e891)

ECR privado con la imagen pusheada despues de actualizar el codigo y correo el workflow github actgions manual
![image](https://github.com/user-attachments/assets/a362806a-c571-47f7-b501-c613871450de)

 ECS atualizado con la imagen del ECR privado despues de correr el pipeline
  ![image](https://github.com/user-attachments/assets/c80e1a39-4f50-4829-b834-428956f9766b)


- 
  


