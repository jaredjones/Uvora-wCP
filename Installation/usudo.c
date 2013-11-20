/*
** Owned By: Uvora LLC
** Created By: Jared Jones
*/
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

static const char statementLength = 36;

int main(int argc, const char * argv[])
{
    if (argv[1] == 0)
    {
	printf("USudo requires at least 1 argument!\n");
	return -2;
    }
    if (!setuid(geteuid()))
    {


        long tmp = 0;
	int i = 1;
        for (i; i < argc; i++)
            tmp += strlen(argv[i]);
        char str[(argc - 1) + tmp + statementLength];
	
	strcpy(str, "/bin/echo '");
	
	int j = 1;
	for (j; j < argc; j++)
	{
	    strcat(str, argv[j]);
	    strcat(str, " ");
	}
	strcat(str, "> /dev/null 2>&1' | /usr/bin/at now");
	//char buffer[3];//2 Char + NullTerm
	//snprintf(buffer, sizeof(buffer), "%%s");	
	//printf("%s\n", buffer);
	//printf("SIZEOFBUFFER:%lu\n", sizeof(buffer));
	printf("%s\n", str);
	printf("UID:%i\n", geteuid());
	system(str);
    }
    else
    {
        printf("USudo is unable to set the itself to the file's owner UID.\n");
        return -1;
    }
    return 0;
}

