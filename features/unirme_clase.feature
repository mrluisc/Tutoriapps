# coding: utf-8
# language: es
Característica: Unirme a una Clase
  
  Como estudiante
  Para saber quién está conmigo en una clase
  Y poder solicitar ayuda a las personas adecuadas
  Quiero poder unirme al grupo de una clase específica

  Escenario: Administrador crea un grupo
    Dado que un administrador ha iniciado sesión
    Cuando intente crear un grupo nuevo
    Entonces el grupo quedará registrado en el sistema

  Escenario: Estudiante crea un grupo
    Dado que un estudiante ha iniciado sesión
    Cuando intente crear un grupo nuevo
    Entonces el grupo no quedará registrado en el sistema

  Escenario: Acceder a un grupo que pertenezco
    Dado que un usuario ha iniciado sesión
    Y que el usuario está matriculado en la materia "Cálculo II"
    Cuando intente acceder al grupo "Cálculo II"
    Entonces podrá ver la información del grupo "Cálculo II"

  @wip
  Escenario: Acceder a un grupo que no pertenezco
    Dado que un usuario ha iniciado sesión
    Pero el usuario no está matriculado en la clase "Cálculo II"
    Entonces no podrá ver la información del grupo

  Escenario: Ver mis grupos