print()
print()
print("====Target Code====")
print()
print()
ot = ""
s = ""
e = open("output.txt", "r")
er = e.read()
s = er
e.close()
Exp = s.split('\n')
#print("Exp",Exp)
sp_count = 0
variables = []


def getRegisterNumber(s,index):
    newStr=s[index:]
    number=int(newStr)
    number=number%13
    inString=str(number)
    return inString


def printForOperators(a,arg1,op,arg2,flag):
    if(flag==1):
        print(op+" R14,",end = " ")
        print(arg1,end = "")
        print(",",end="")
        print(arg2)
        print("MOV ",a,",R14")
    else:
        print(op+" R14,",end = " ")
        print(arg1,end = "")
        print(",",end="")
        print(arg2)
        print("STR R14,",a)



def printAssemblyCode(c):
    global sp_count
    global variables
    QTemp=c.split(" ")
    if(QTemp[0].find("L")!=-1):
        print(QTemp[0],end="")
        i=1
        s=""
        while(i<len(QTemp)):
            if i==(len(QTemp)-1):
                s=s+QTemp[i]
            else:
                s=s+QTemp[i]+" "
            i=i+1
        printAssemblyCode(s)

    elif(c.find("If False") == -1):
        if(c.find("goto") != -1):
            branch = c.split(" ")
            print("B ",end=" ")
            print(branch[1],end=" ")
            print("")         
        elif(c.find("param") != -1):
            para = c.split(" ")
            print("str ",end=" ")
            print(para[1],end=" ")
            print(" , sp(",end=" ")
            print(sp_count,end=" ")
            sp_count += 1
            print(")")
            variables.append(para[1])
        elif(c.find("call") != -1):
            print("call ",end="")
            print(c[5 : c.find(",")],end=" ")
            #print(" ")
            print(c[c.find(",")  : ])         
        elif(c.find("=") != -1):
            #print("c",c)
            expression = c.split(" ")
            if(len(expression) == 3):
                if expression[2].isnumeric():
                    if(expression[0].find("T")!=-1):
                        print("MOV R0",end = "")
                        print(",#",expression[2])
                        index=expression[0].find('T')+1
                        registerNumber=getRegisterNumber(expression[0],index)
                        print("MOV R",registerNumber,",R0")
                        #print("STR R0,",expression[0],end="")
                        print("")
                    else:
                         if expression[0] not in variables:
                             variables.append(expression[0])
                         print("MOV R0",end = "")
                         print(",#",expression[2])
                         print("STR R0,",expression[0],end="")
                         print("")

                elif(expression[2]=='True'):
                    expression[2]=1
                    if(expression[0].find("T")!=-1):
                        print("MOV R0",end = "")
                        print(", #",expression[2])
                        index=expression[0].find('T')+1
                        registerNumber=getRegisterNumber(expression[0],index)
                        print("MOV R",registerNumber,",R0")
                        #print("STR R0,",expression[0],end="")
                        print("")
                    else:
                         if expression[0] not in variables:
                             variables.append(expression[0])
                         print("MOV R0",end = "")
                         print(", #",expression[2])
                         print("STR R0,",expression[0],end="")
                         print("")
                    
                elif(expression[2]=='False'):
                    expression[2]=0
                    if(expression[0].find("T")!=-1):
                        print("MOV R0",end = "")
                        print(", #",expression[2])
                        index=expression[0].find('T')+1
                        registerNumber=getRegisterNumber(expression[0],index)
                        print("MOV R",registerNumber,",R0")
                        #print("STR R0,",expression[0],end="")
                        print("")
                    else:
                         if expression[0] not in variables:
                             variables.append(expression[0])
                         print("MOV R0",end = "")
                         print(", #",expression[2])
                         print("STR R0,",expression[0],end="")
                         print("")
                    
                elif expression[2].find('T')!=-1:
                    if(expression[0].find("T")!=-1):
                        #print("LDR R",end="")
                        index=expression[2].find('T')+1
                        registerNumberRight=getRegisterNumber(expression[2],index)
                        index=expression[0].find('T')+1
                        registerNumberLeft=getRegisterNumber(expression[0],index)
                        print("MOV R",registerNumberLeft,",R",registerNumberRight)
                        #print(registerNumber,",",expression[2])
                        #print("STR",end=" ")
                        #print("R",registerNumber,end = "")
                        #print(" , ",end = "")
                        #print(expression[0])
                    else:
                         if expression[0] not in variables:
                             variables.append(expression[0])
                         index=expression[2].find('T')+1
                         registerNumber=getRegisterNumber(expression[2],index)  
                         print("STR R",registerNumber,",",expression[0])


                else:
                    if expression[2] not in variables:
                        variables.append(expression[2])
                    print("LDR R14,",expression[2])
                    index=expression[0].find('T')+1
                    registerNumber=getRegisterNumber(expression[0],index)  
                    print("MOV R",registerNumber,",R14")
            else: 
                r = "R"
                flag=-1
                if(expression[0].find("T")!=-1):
                    flag=1
                    index=expression[0].find('T')+1
                    registerNumber=getRegisterNumber(expression[0],index)
                    a = r+registerNumber
                else:
                    flag=0
                    a=expression[0]
                #print("expr",expression)
                arg1 = expression[2]
                opr = expression[3]
                arg2 = expression[4]                
                if(arg1.find('T') != -1):
                    index=arg1.find('T')+1
                    registerNumber=getRegisterNumber(arg1,index)
                    arg1 = r + registerNumber               
                if(arg2.find('T') != -1):
                    index=arg2.find('T')+1
                    registerNumber=getRegisterNumber(arg2,index)
                    arg2 =r + registerNumber                                   
                if(opr.find(">") != -1):
                    printForOperators(a,arg1,"GT",arg2,flag)
                if(opr.find("<") != -1):
                    printForOperators(a,arg1,"LT",arg2,flag)
                if(opr.find("+") != -1):
                    printForOperators(a,arg1,"ADD",arg2,flag)
                if(opr.find("-") != -1):
                    printForOperators(a,arg1,"SUB",arg2,flag)
                if(opr.find("*") != -1):
                    printForOperators(a,arg1,"MUL",arg2,flag)
                if(opr.find("/") != -1):
                    printForOperators(a,arg1,"DIV",arg2,flag)
                if(opr.find("<=") != -1):
                    printForOperators(a,arg1,"LE",arg2,flag)
                if(opr.find(">=") != -1):
                   printForOperators(a,arg1,"GE",arg2,flag)
                if(opr.find("==") != -1):
                    printForOperators(a,arg1,"EQ",arg2,flag)
                
                                            
        else: 
            print(c)
    else:
        forIf = c.split(" ")
        print("CMP ",end = "")
        print("R",end = "")
        index=forIf[2].find('T')+1
        registerNumber=getRegisterNumber(forIf[2],index)
        print(", 0 ")
        print("BEQ",end=" ")
        print(forIf[4])




for i in range(0, len(Exp)):
    c = Exp[i]
    if(c == "====Optimised intermediate code===="):
        break

while(i<len(Exp)):
    c=Exp[i]
    if(c == "====Optimised intermediate code===="):
        i=i+1
        continue
    elif(c== "\n"):
        i=i+1
        continue
    printAssemblyCode(c)
    i=i+1



print("\n.WORD ")
variables2 = []
check = 0
variables = list(set(variables))
for i in range(0, len(variables)): 
    check = 0
    for j in range(0, len(variables2)):
        if(variables[i] == ((variables2[j]) == 1)):
            check = 1
            break    
    if(not check):
        print(variables[i],end = " ")
        variables2.append(variables[i])
        if(i + 1 < len(variables)):
            print(" , ",end="")
print("")
