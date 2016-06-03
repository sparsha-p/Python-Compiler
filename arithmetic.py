def arithmetic(formula):
    polish = []
    op = []
    mark = 0
    op.append('#')
    for i in range(len(formula)):
        if ((ord(formula[i]) >= 48) and (ord(formula[i]) <= 57)):
            continue
        else:
            if i != mark:
                temp = formula[mark : i]
                polish.append(temp)
            mark = i + 1
            if (formula[i] == '+'):
                while (len(op) != 1):
                    if (op[len(op) - 1] != '('):
                        polish.append(op[len(op) - 1])
                        op.pop()
                    else:
                        break
                op.append('+')
            elif (formula[i] == '-'):
                while (len(op) != 1):
                    if (op[len(op) - 1] != '('):
                        polish.append(op[len(op) - 1])
                        op.pop()
                    else:
                        break
                op.append('-')
            elif (formula[i] == '*'):
                while (len(op) != 1):
                    if ((op[len(op) - 1] == '*') or (op[len(op) - 1] == '/')):
                        polish.append(op[len(op) - 1])
                        op.pop()
                    else:
                        break
                op.append('*')
            elif (formula[i] == '/'):
                while (len(op) != 1):
                    if ((op[len(op) - 1] == '*') or (op[len(op) - 1] == '/')):
                        polish.append(op[len(op) - 1])
                        op.pop()
                    else:
                        break
                op.append('/')
            elif (formula[i] == '('):
                op.append('(')
            elif (formula[i] == ')'):
                while (len(op) != 1):
                    if (op[len(op) - 1] != '('):
                        polish.append(op[len(op) - 1])
                        op.pop()
                    elif (i == len(formula) - 1):
                        op.pop()
                    else:
                        op.pop()
                        break
    temp = formula[mark : len(formula)]
    polish.append(temp)
    while (len(op) != 1):
        polish.append(op[len(op) - 1])
        op.pop()
    result = []
    for i in range(len(polish)):
        if (polish[i].isdigit()):
            result.append(polish[i])
        else:
            length = len(result)
            num1 = float(result[length - 2])
            num2 = float(result[length - 1])
            if (polish[i] == '+'):
                res = num1 + num2
            elif (polish[i] == '-'):
                res = num1 - num2
            elif (polish[i] == '*'):
                res = num1 * num2
            elif (polish[i] == '/'):
                res = num1 / num2
            res = str(res)
            result[length - 2] = res
            result.pop(length - 1)
    print(result[0])
