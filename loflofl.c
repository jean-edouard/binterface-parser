#include <stdlib.h>
#include <stdio.h>
#include <string.h>

typedef struct {
  unsigned char id;
  char *value;
} protocol_t;

typedef struct {
  unsigned char id;
  char *value;
  protocol_t *prots;
} subclass_t;

typedef struct {
  unsigned char id;
  char *value;
  subclass_t *subs;
} class_t;

#include "classes.h"

#define CLASS    0xe0
#define SUBCLASS 0x01
#define PROTOCOL 0x01

char* device_type(unsigned char class,
		  unsigned char subclass,
		  unsigned char protocol)
{
  const class_t *tmp = classes;
  int n = 0;
  int m = 0;
  int size;
  char *res;

  /* Find the class */
  while (tmp->value != NULL && tmp->id != class)
    tmp++;
  if (tmp->value == NULL)
    return NULL;

  /* Find the subclass */
  while (tmp->subs != NULL && tmp->subs[n].value != NULL &&
	 tmp->subs[n].id != subclass)
    n++;
  if (tmp->subs == NULL || tmp->subs[n].value == NULL)
    {
      size = strlen(tmp->value) + 1;
      res = malloc(size);
      snprintf(res, size, "%s", tmp->value);
      return res;
    }

  /* Find the protocol */
  while (tmp->subs[n].prots != NULL && tmp->subs[n].prots[m].value != NULL &&
	 tmp->subs[n].prots[m].id != protocol)
    m++;
  if (tmp->subs[n].prots == NULL || tmp->subs[n].prots[m].value == NULL)
    {
      size = strlen(tmp->value) + 2 + strlen(tmp->subs[n].value) + 1;
      res = malloc(size);
      snprintf(res, size, "%s, %s", tmp->value, tmp->subs[n].value);
      return res;
    }

  /* Everything was found */
  size = strlen(tmp->value) + 2 +
    strlen(tmp->subs[n].value) + 2 +
    strlen(tmp->subs[n].prots[m].value) + 1;
  res = malloc(size);
  snprintf(res, size, "%s, %s, %s",
	   tmp->value,
	   tmp->subs[n].value,
	   tmp->subs[n].prots[m].value);

  return res;
}

int main()
{
  char *type;

  type = device_type(CLASS, SUBCLASS, PROTOCOL);

  if (type == NULL)
    return 1;

  printf("%s\n", type);

  free(type);

  return 0;
}
