from calendar import month
from datetime import date, datetime
from django.http import HttpResponse, JsonResponse
from django.shortcuts import redirect, render
import random  # Add this at the top of your file

from . models import Buy, BuyDetail, Feedback, GovtStaff, Login, Notification, Payment, Product, ProductType, Rating, RationCard, RequestRationCard, Shop, StaffDetail, Stock, StockDetail, TimeAllocate, Type, User

# Create your views here.
from . models import *



# def loginuser(request):
#     uname=request.POST['username1']
#     pwd=request.POST['password']
#     print("username=",uname)
#     print("password=",pwd)
#     queryset=Login.objects.filter(username=uname, password = pwd)
#     if not queryset.exists():
#         return JsonResponse({'status': 'error','message':'Invalid username or password'})
#     login_obj = queryset.first()
#     response={
#         'status':'success',
#         'message':'Login successfull',
#         'usertype':login_obj.usertype,
#         'login_id':login_obj.id
#     }
#     if login_obj.usertype=='user':
#         try:
#             user= User.objects.get(login_id=login_obj.id)
#             response['address']=user.place
#             response['phone'] = user.phone
#         except User.DoesNotExist:
#             response['address']=""
#             response['phone']=""
#             response['profile_image']=None
#     return JsonResponse("sucess")


def home(request):
    return render(request,'Instant/index.html')

def ahome(request):
    return render(request,'Admin/home.html')

def gshome(request):
    return render(request,'Gs/home.html')

def skhome(request):
    return render(request,'Sk/home.html')

def login(request):
    if 'login' in request.POST:
        u=request.POST['uname']
        p=request.POST['pwd']
    
        try:
            o=Login.objects.get(username=u,password=p)
            if o.usertype=='admin':
                return HttpResponse("<script>alert('Welcome to the home page');window.location='/ahome';</script>")
            if o.usertype=='gs':
                g=GovtStaff.objects.get(login_id=o.id)
                request.session['gid']=g.id
                return HttpResponse("<script>alert('Welcome to the home page');window.location='/gshome';</script>")
            if o.usertype=='sk':
                s=Shop.objects.get(login_id=o.id)
                request.session['sid']=s.id
                return HttpResponse("<script>alert('Welcome to the home page');window.location='/skhome';</script>")
        except:
            return HttpResponse("<script>alert('Incorrect Username and Password');window.location='/login';</script>")
    return render(request,'login.html')

#Admin Module
def rtype(request):
        o=Type.objects.all()
        if 'submit' in request.POST:
            name=request.POST['name']
            d=request.POST['d']
            t=Type(name=name,details=d)
            t.save()
            return HttpResponse("<script>alert('Ration Card type added successfully');window.location='/rtype';</script>")
        return render(request,'Admin/rtype.html',{'o':o})

def rtedit(request,id):
        z=Type.objects.get(id=id)
        o=Type.objects.all()
        if 'edit' in request.POST:
            z.name=request.POST['name']
            z.details=request.POST['d']
            z.save()
            return HttpResponse("<script>alert('Ration Card type edited successfully');window.location='/rtype';</script>")
        return render(request,'Admin/rtype.html',{'o':o,'z':z})


def rtdelete(request,id):
    d=Type.objects.get(id=id)
    d.delete()
    return HttpResponse("<script>alert('Ration Card Type deleted successfully');window.location='/rtype';</script>")

def gs(request):
    o=GovtStaff.objects.all()
    if 'submit' in request.POST:
        fname=request.POST['fname']
        lname=request.POST['lname']
        phone=request.POST['phone']
        email=request.POST['email']
        place=request.POST['place']
        designation=request.POST['designation']
        u=request.POST['username']
        p=request.POST['password']
        l=Login(username=u,password=p,usertype='gs')
        l.save()
        g=GovtStaff(fname=fname,lname=lname,phone=phone,email=email,place=place,designation=designation,login_id=l.pk)
        g.save()
        return HttpResponse("<script>alert('Government Staff added successfully');window.location='/gs';</script>")
    return render(request,'Admin/gs.html',{'o':o})

def gsedit(request,id):
    z=GovtStaff.objects.get(id=id)
    o=GovtStaff.objects.all()
    if 'edit' in request.POST:
        z.fname=request.POST['fname']
        z.lname=request.POST['lname']
        z.phone=request.POST['phone']
        z.email=request.POST['email']
        z.place=request.POST['place']
        z.designation=request.POST['designation']
        z.save()
        return HttpResponse("<script>alert('Government Staff edited successfully');window.location='/gs';</script>")
    return render(request,'Admin/gs.html',{'o':o,'z':z})

def gsdelete(request,id):
    d=GovtStaff.objects.get(id=id)
    d.delete()
    return HttpResponse("<script>alert('Government Staff deleted successfully');window.location='/gs';</script>")


def products(request):
    o=Product.objects.all()
    if 'submit' in request.POST:
        a=request.POST['product']
        b=request.POST['details']
        c=request.POST['amount']
        q=Product(product=a,details=b,amount=c)
        q.save()
        return HttpResponse("<script>alert('Product added successfully');window.location='/products';</script>")
    return render(request,'Admin/products.html',{'o':o})

def pedit(request,id):
    z=Product.objects.get(id=id)
    o=Product.objects.all()
    if 'edit' in request.POST:
        z.product=request.POST['product']
        z.details=request.POST['details']
        z.amount=request.POST['amount']
        z.save()
        return HttpResponse("<script>alert('Product edited successfully');window.location='/products';</script>")
    return render(request,'Admin/products.html',{'o':o,'z':z})

def pdelete(request,id):
    d=Product.objects.get(id=id)
    d.delete()
    return HttpResponse("<script>alert('Product deleted successfully');window.location='/products';</script>")

def request(request):
    o=StaffDetail.objects.all()
    t=Type.objects.all()
    if 'submit' in request.POST:
        c=request.POST['type']
        b=request.POST['rid']
        a = random.randint(10**11, (10**12)-1)
        d=RationCard(cardnumber=a,date=datetime.now(),request_id=b,type_id=c)
        d.save()
        e=RequestRationCard.objects.get(id=b)
        e.status = 'Ration Card Generated'
        e.save()
        f=StaffDetail.objects.get(request_id=b)
        f.status = 'Ration card generated'
        f.save()
        return HttpResponse("<script>alert('Ration card generated successfully');window.location='/request';</script>")
    return render(request,'Admin/request.html',{'o':o,'t':t})

def feedback(request):
    o=Feedback.objects.all()
    return render(request,'Admin/feedback.html',{'o':o})

def asd(request,id):
    o=GovtStaff.objects.get(id=id)
    return render(request,'Admin/asd.html',{'i':o})

def aud(request,id):
    o=User.objects.get(id=id)
    return render(request,'Admin/aud.html',{'i':o})

def req(request):
    o=RequestRationCard.objects.all()
    return render(request,'Gs/req.html',{'o':o})

def ud(request,id):
    o=User.objects.get(id=id)
    req=RequestRationCard.objects.get(user_id=o.id)
    rid=req.id
    if 'submit' in request.POST:
        d=request.POST['d']
        s=StaffDetail(detail=d,status='Forwarded by staff',request_id=rid,staff_id_id=request.session['gid'])
        s.save()
        req.status='Forwarded by staff'
        req.save()
        return HttpResponse("<script>alert('Passed to admin');window.location='/req';</script>")
    return render(request,'Gs/ud.html',{'i':o})

#Shopkeeper Module

def reg(request):
    if 'submit' in request.POST:
        fname=request.POST['fname']
        lname=request.POST['lname']
        phone=request.POST['phone']
        email=request.POST['email']
        place=request.POST['place']
        shop=request.POST['shop']
        u=request.POST['username']
        p=request.POST['password']
        l=Login(username=u,password=p,usertype='sk')
        l.save()
        g=Shop(fname=fname,lname=lname,phone=phone,email=email,place=place,shop=shop,login_id=l.pk)
        g.save()
        return HttpResponse("<script>alert('Shop regisered successfully');window.location='/';</script>")
    return render(request,'Sk/reg.html')


def pt(request):
    o=Product.objects.all()
    t=Type.objects.all()
    q=ProductType.objects.all()
    if 'submit' in request.POST:
        a=request.POST['p']
        g=request.POST['type']
        c=request.POST['kl']
        d=request.POST['month']
        p=ProductType(kiloorlitter=c, forthemonth=d,product_id=a,type_id=g)
        p.save()
        return HttpResponse("<script>alert('Assigned');window.location='/pt';</script>")
    return render(request,'Gs/pt.html',{'o':o,'t':t, 'q':q})

def ptedit(request,id):
    z=ProductType.objects.get(id=id)
    o=Product.objects.all()
    t=Type.objects.all()
    q=ProductType.objects.all()
    if 'submit' in request.POST:
        z.product_id=request.POST['p']
        z.type_id=request.POST['type']
        z.kiloorlitter=request.POST['kl']
        z.forthemonth=request.POST['month']
        z.save()
        return HttpResponse("<script>alert('Edited successfully');window.location='/pt';</script>")
    return render(request,'Gs/pt.html',{'o':o,'t':t, 'q':q,'z':z})

def ptdelete(request,id):
    d=ProductType.objects.get(id=id)
    d.delete()
    return HttpResponse("<script>alert('Product type deleted successfully');window.location='/pt';</script>")

def vsk(request):
    o=Shop.objects.all()
    return render(request,'Gs/vsk.html',{'o':o})

def vsd(request,id):
    o=Stock.objects.filter(shop_id=id)
    return render(request,'Gs/vsd.html',{'o':o})

def notification(request):
    if 'submit' in request.POST:
        a=request.POST['n']
        b=request.POST['d']
        n=Notification(notification=a,details=b,date=datetime.now())
        n.save()
        return HttpResponse("<script>alert('Notificattion send successfully');window.location='/notification';</script>")
    return render(request,'Gs/notification.html')

def prt(request):
    o=Product.objects.all()
    t=Type.objects.all()
    z=[]
    a=''
    if 'submit' in request.POST:
        b=request.POST['type']
        z=ProductType.objects.filter(type=b)
        a=Type.objects.get(id=b)
        if not z:
            return HttpResponse("<script>alert('No products found');window.location='/prt';</script>")
    return render(request,'Sk/prt.html',{'o':o,'t':t,'z':z,'a':a})

def rc(request):
    z=[]
    a=''
    if 'submit' in request.POST:
        b=request.POST['n']
        z=RationCard.objects.get(cardnumber=b)
        a=ProductType.objects.filter(type_id=z.type_id)
        print(z)
    return render(request,'Sk/rc.html',{'z':z,'a':a})

def sktime(request):
    a=TimeAllocate.objects.all()
    return render(request,'Sk/sktime.html',{'a':a})

# def viewslotproducts(request, id):
#     a = TimeAllocate.objects.get(id=id, status='requested by user')
#     a.status = 'verified by shopkeeper'
#     tid=id

#     b = Buy.objects.get(user_id=a.user_id)
#     all_details = BuyDetail.objects.filter(buy_id=b.id)

#     # Get list of verified product IDs for this slot from session
#     verified_ids = request.session.get(f'verified_{id}', [])

#     # Check if all products are verified
#     if all(d.product.id in verified_ids for d in all_details):
#         return redirect('/timeslot?status=verified')

#     return render(request, 'Sk/slotproduct.html', {
#         'a': a,
#         'e': all_details,
#         'verified_ids': verified_ids,
#         'slot_id': id,
#         'tid':tid,
#     })

# def verify(request, product_id, quantity, slot_id,tid):
#     stock_id = request.session['sid']
#     s = StockDetail.objects.get(product_id=product_id, stock_id=stock_id)
#     f=s.kiloorlitter
#     s.kiloorlitter =int(f)- int(quantity)
#     s.save()

#     if 'submit' in request.POST:
#         a = TimeAllocate.objects.get(id=tid, status='requested by user')
#         a.status = 'verified by shopkeeper'
#         a.save()

#     # Mark product as verified in session
#     verified_key = f'verified_{slot_id}'
#     verified_ids = request.session.get(verified_key, [])
#     if product_id not in verified_ids:
#         verified_ids.append(product_id)
#         request.session[verified_key] = verified_ids
#         request.session.modified = True

#     return redirect(f'/viewslotproducts/{slot_id}')

from django.shortcuts import render, redirect, get_object_or_404
from .models import TimeAllocate, Buy, BuyDetail, StockDetail

# def viewslotproducts(request, id):
#     a = get_object_or_404(TimeAllocate, id=id)
#     tid = id

#     b = get_object_or_404(Buy, user_id=a.user_id)
#     all_details = BuyDetail.objects.filter(buy_id=b.id)

#     verified_ids = request.session.get(f'verified_{id}', [])

#     if 'submit' in request.POST:
#         if all(d.product.id in verified_ids for d in all_details):
#             a.status = 'verified by shopkeeper'
#             a.save()
#             return HttpResponse("<script>alert('Slot Verified');window.location='/sktime';</script>")

#     return render(request, 'Sk/slotproduct.html', {
#         'a': a,
#         'e': all_details,
#         'verified_ids': verified_ids,
#         'slot_id': id,
#         'tid': tid,
#     })

# def verify(request, product_id, quantity, slot_id, tid):
#     stock_id = request.session.get('sid')
#     s = get_object_or_404(StockDetail, product_id=product_id, stock_id=stock_id)
    
#     s.kiloorlitter = int(s.kiloorlitter) - int(quantity)
#     s.save()

#     verified_key = f'verified_{slot_id}'
#     verified_ids = request.session.get(verified_key, [])

#     if product_id not in verified_ids:
#         verified_ids.append(product_id)
#         request.session[verified_key] = verified_ids
#         request.session.modified = True

#     return redirect(f'/viewslotproducts/{slot_id}')


from django.shortcuts import render, redirect, get_object_or_404
from django.http import HttpResponse
from .models import TimeAllocate, Buy, BuyDetail, StockDetail

def viewslotproducts(request, id):
    a = get_object_or_404(TimeAllocate, id=id)
    tid = id

    # Get the latest Buy for the user (handles MultipleObjectsReturned)
    b = Buy.objects.filter(user_id=a.user_id).order_by('-id').first()
    if not b:
        return HttpResponse("No Buy record found for this user.", status=404)

    all_details = BuyDetail.objects.filter(buy_id=b.id)

    # Get verified product IDs from session
    verified_ids = request.session.get(f'verified_{id}', [])

    if request.method == 'POST' and 'submit' in request.POST:
        if all(d.product.id in verified_ids for d in all_details):
            a.status = 'verified by shopkeeper'
            a.save()
            # Clear the session data after successful verification
            del request.session[f'verified_{id}']
            return HttpResponse("<script>alert('Slot Verified');window.location='/sktime';</script>")
        else:
            return HttpResponse("<script>alert('Please verify all products first.');window.history.back();</script>")

    return render(request, 'Sk/slotproduct.html', {
        'a': a,
        'e': all_details,
        'verified_ids': verified_ids,
        'slot_id': id,
        'tid': tid,
    })


def verify(request, product_id, quantity, slot_id, tid):
    stock_id = request.session.get('sid')
    s = get_object_or_404(StockDetail, product_id=product_id, stock_id=stock_id)

    s.kiloorlitter = int(s.kiloorlitter) - int(quantity)
    s.save()

    verified_key = f'verified_{slot_id}'
    verified_ids = request.session.get(verified_key, [])

    if product_id not in verified_ids:
        verified_ids.append(product_id)
        request.session[verified_key] = verified_ids
        request.session.modified = True

    return redirect(f'/viewslotproducts/{slot_id}')


def skrating(request):
    a=Rating.objects.all()
    return render(request,'Sk/skrating.html',{'a':a})

def skstock(request):
    m=Product.objects.all()
    if 'submit' in request.POST:
        stid=request.POST['stid']
        a=request.POST['kl']
        b=request.POST['pid']
        try:
            q=StockDetail.objects.get(id=stid)
            q.kiloorlitter=a
            q.save()
        except:
            s=Stock(date=datetime.now(),shop_id=request.session['sid'])
            s.save()
            n=StockDetail(kiloorlitter=a,product_id=b,stock_id=s.pk)
            n.save()
        return HttpResponse("<script>alert('Stock details Added successfully');window.location='/skstock';</script>")
    return render(request,'Sk/skstock.html',{'m':m})

def stdelete(request,id):
    d=StockDetail.objects.get(product_id=id)
    a=d.stock_id
    d.delete()
    e=Stock.objects.get(id=a)
    e.delete()
    return HttpResponse("<script>alert('Stock Deleted successfully');window.location='/skstock';</script>")

    return HttpResponse("<script>alert('Ration Card Type deleted successfully');window.location='/rtype';</script>")





def loginuser(request):
    username = request.POST.get('username1')
    password = request.POST.get('password')
    print(username, password)

    queryset = Login.objects.filter(username=username, password=password)

    if not queryset.exists():
        return JsonResponse({'status': "error", 'message': 'Invalid username or password'})

    login_obj = queryset.first()

    response = {
        'status': 'success',
        'message': 'Login successful',
        'usertype': login_obj.usertype,
        'login_id': login_obj.id
    }

    if login_obj.usertype == 'user':
        try:
            user = User.objects.get(login_id=login_obj.id)
            # response['address'] = user.address
            response['phone'] = user.phone
            # response['profile_image'] = user.proifilepic.url if user.proifilepic else None  # Make sure 'proifilepic' is not a typo
        except User.DoesNotExist:
            response['address'] = ""
            response['phone'] = ""

    return JsonResponse(response)

def reguser(request):
    uname=request.POST.get('uname')
    pwd=request.POST.get('password')
    fname=request.POST.get('first_name')
    lname=request.POST.get('last_name')
    hname=request.POST.get('hname')
    ward=request.POST.get('ward')
    hno=request.POST.get('hno')
    place=request.POST.get('place')
    phone=request.POST.get('phone')
    email=request.POST.get('email')
    designation=request.POST.get('designation')
    age=request.POST.get('age')
    gender=request.POST.get('gender')
    l=Login(username=uname,password=pwd,usertype='user')
    l.save()
    a=User(fname=fname,lname=lname,hname=hname,ward=ward,hno=hno,place=place,age=age,gender=gender,phone=phone,email=email,designation=designation,login=l)
    a.save()
    response = {
        'status': 'success',
        'message': 'Registration successful',
    }

    return JsonResponse(response)

# from django.http import JsonResponse
# import json

# def reguser(request):
#     if request.method == "POST":
#         try:
#             # Try multipart/form-data (Flutter's MultipartRequest)
#             uname = request.POST.get('uname')
#             pwd = request.POST.get('password')
#             fname = request.POST.get('first_name')
#             lname = request.POST.get('last_name')
#             hname = request.POST.get('hname')
#             ward = request.POST.get('ward')
#             hno = request.POST.get('hno')
#             place = request.POST.get('place')
#             phone = request.POST.get('phone')
#             email = request.POST.get('email')
#             designation = request.POST.get('designation')
#             age = request.POST.get('age')
#             gender = request.POST.get('gender')

#             # If POST is empty, try JSON body
#             if not uname:
#                 data = json.loads(request.body.decode("utf-8"))
#                 uname = data.get('uname')
#                 pwd = data.get('password')
#                 fname = data.get('first_name')
#                 lname = data.get('last_name')
#                 hname = data.get('hname')
#                 ward = data.get('ward')
#                 hno = data.get('hno')
#                 place = data.get('place')
#                 phone = data.get('phone')
#                 email = data.get('email')
#                 designation = data.get('designation')
#                 age = data.get('age')
#                 gender = data.get('gender')

#             # Save to DB
#             l = Login(username=uname, password=pwd, usertype='user')
#             l.save()
#             a = User(fname=fname, lname=lname, hname=hname, ward=ward,
#          hno=hno, place=place, age=age, gender=gender,
#          phone=phone, email=email, designation=designation,
#          login=l.pk)  

#             a.save()

#             return JsonResponse({
#                 'status': 'success',
#                 'message': 'Registration successful',
#             })

#         except Exception as e:
#             return JsonResponse({'status': 'error', 'message': str(e)}, status=400)

#     return JsonResponse({'status': 'error', 'message': 'Invalid request'}, status=405)


def userfeedback(request):
    f=request.POST.get('feedback')
    lid=request.POST.get('lid')
    id=User.objects.get(login_id=lid)
    o=Feedback(feedback=f,date=datetime.now(),user_id=id.id)
    o.save()
    response={
        'status':'success',
        'message':'Feedback Send Successfully',
    }
    return JsonResponse(response)

def view_feedback(request):
    data=[]
    queryset=Feedback.objects.all()
    for feedback in queryset:
        data.append({
            'id': feedback.id,
            'customer_name': feedback.user.fname + ' ' + feedback.user.lname,
            'feedback_date': feedback.date,
            'feedback_text': feedback.feedback,
        })
    if data:
        return JsonResponse({
            'status': 'true',
            'message': 'Feedback retrieved successfully',
            'data': data
        })
    else:
        return JsonResponse({'status': 'error', 'message': 'No feedback found'})

    return JsonResponse(i)

def pdetails(request):
    data=[]
    e=date.today().month
    a=request.POST.get('lid')
    b=User.objects.get(login_id=a)
    c=RequestRationCard.objects.get(user_id=b.id)
    d=RationCard.objects.get(request_id=c.id)
    q=ProductType.objects.filter(type_id=d.type_id, forthemonth = e)
    z=BuyDetail.objects.all()
    li=z.values_list('id', flat=True)
    
    for d in q:
            data.append({
                'id':d.id,
                'product_name':d.product.product,
                'KiloLiter':d.kiloorlitter,
                'amount':d.product.amount,
            })
    if data:
        response={
            'status':'true',
            'data':data,
        }
    else:
        response={
            'status':'error',
            'message':'No products found',
        }
    return JsonResponse(response)

def view_req(request):
    u=request.POST.get('lid')
    print(u)
    o=User.objects.get(login_id=u)
    print(o)
    id=o.id
    try:
        p=RequestRationCard.objects.get(user_id=id)
        response={
        'status':'success',
        'message': 'Card already requested'
    }
    except:
        r=RequestRationCard(status='requested by user',user_id=id)
        r.save()
        response={
            'status':'success',
            'message': 'Card requested successfully'
        }
    return JsonResponse(response)

def rstatus(request):
    lid=request.POST.get('lid')
    u=User.objects.get(login_id=lid)
    uid=u.id
    o=RequestRationCard.objects.get(user_id=uid)
    response={
        'reqstatus':o.status,
    }
    return JsonResponse(response)

def rdetails(request):
    lid=request.POST.get('lid')
    u=User.objects.get(login_id=lid)
    o=RequestRationCard.objects.get(user_id=u.id)
    r=RationCard.objects.get(request_id=o.id)
    t=Type.objects.get(id=r.type_id)
    response={
        'cn':r.cardnumber,
        'issued_date':r.date,
        'card_type':t.name,
    }
    return JsonResponse(response)


def notifications(request):
    n= Notification.objects.all()
    data = []
    for i in n:
        data.append({
            'n':i.notification,
            'details': i.details,
            'date':i.date
        })
    response = {
        'data':data,
    }
    return JsonResponse(response)

def usershops(request):
    a= Shop.objects.all()
    data=[]
    for i in a:
        data.append({
            'id':i.id,
            'shopname': i.shop,
            'place': i.place,
            'phone':i.phone,
        })
    response = {
        'data':data
    }
    print(data)
    return JsonResponse(response)

def userslot(request):
    sid=request.POST.get('sid')
    u=request.POST.get('uid')
    ui=User.objects.get(login_id=u)
    uid=ui.pk
    date=request.POST.get('date')
    time=request.POST.get('time')
    try:
        a=Buy.objects.filter(user_id=uid, status='slot booked')
        response = {
            'status':'success',
            'message':'Complete the Purchase'
        }
    except:
        o=TimeAllocate(date=date, time=time, status ='requested by user',user_id=uid,shop_id=sid)
        o.save()
        a=Buy.objects.get(user_id=uid, status='Payement Done')
        a.status='slot booked'
        response = {
            'status':'success',
            'message':'redirecting'
        }
    return JsonResponse(response)

def cart(request):
    producttype=request.POST.get('p')
    l=request.POST.get('lid')
    t=ProductType.objects.get(id=producttype)
    p=t.product_id
    q=t.kiloorlitter
    c=User.objects.get(login_id=l)
    u=c.id
    a=Product.objects.get(id=p)
    amt = a.amount
    try:
        b=Buy.objects.get(user_id=u, status='payment pending')
        try:
            o=BuyDetail.objects.get(product_id=p, buy_id=b.pk)
            response={
                'status':'kkkkkkk',
                'message':'Product already collected'
            }
        except BuyDetail.DoesNotExist:
            c=BuyDetail(quantity=q,amount= amt, buy_id=b.pk,product_id=p)
            b.tamount += amt
            b.save()
            c.save()
            response={
            'status':'success',
            'message':'Added'
            }
    except Buy.DoesNotExist:
        b=Buy(tamount=amt, date = datetime.now, user_id =u, status='payment pending')
        b.save()
        c=BuyDetail(quantity=q,amount= amt, buy_id=b.pk,product_id=p)
        c.save()
        response={
            'status':'success',
            'message':'Added',
        }
    return JsonResponse(response)

def userviewcart(request):
    data=[]
    try:
        lid=request.POST.get('lid')
        u=User.objects.get(login_id=lid)
        b=Buy.objects.get(user_id=u.pk, status ='payment pending')
        c=BuyDetail.objects.filter(buy_id=b.pk)
        p=Payment.objects.all()
        for i in c:
                data.append({
                    'pname':i.product.product,
                    'quantity':i.quantity,
                    'amount':i.product.amount,
                })
        response = {
            'data':data,
            'bid':b.pk,
            'total':b.tamount,
        }
    except:
        response = {
            'data':data,
            'bid':'',
        }
    return JsonResponse(response)

def rate(request):
    rsid=request.POST.get('rsid')
    lid=request.POST.get('lid')
    r=request.POST.get('rating')
    u=User.objects.get(login_id=lid)
    uid=u.id
    try:
        z=Rating.objects.get(user_id=uid, shop_id=rsid)
        z.rated = r
        z.date= datetime.now()
        z.save()
        response = {
        'status':'success',
        'message':'Rating updated successfully'
    }
    except:
        a=Rating(rated=r,date=datetime.now(), shop_id=rsid, user_id=uid)
        a.save()
        response = {
        'status':'success',
        'message':'Rating added successfully'
    }
    return JsonResponse(response)

def payment(request):
    bid=request.POST.get('bid')
    print(bid)
    response = {
        'status':'success',
        'message': 'Payment Successfull'
    }
    b=Buy.objects.get(id=bid)
    b.status='Payement Done'
    b.save()
    p=Payment(amount=b.tamount,date=datetime.now(),buy_id=bid)
    p.save()
    return JsonResponse(response)

def viewrate(request):
    data=[]
    uid=request.POST.get('uid')
    u=User.objects.get(login_id=uid)
    sid=request.POST.get('sid')
    r=Rating.objects.get(user_id=u.id, shop_id=sid)
    print('gggggggggggggggggggggggggggggggggggggggg')
    responce={
        'rated':r.rated,
        'date':r.date,
    }
    print(r.rated)
    return JsonResponse(responce)

def slothistory(request):
    lid=request.POST.get('lid')
    u=User.objects.get(login_id=lid)
    sid=request.POST.get('sid')
    o=TimeAllocate.objects.filter(user_id=u.id,shop_id=sid)
    print(o)
    data=[]
    for i in o:
        data.append({
            'date':i.date,
            'time':i.time,
            'status':i.status,
        })
    responce={
        'data':data,
    }
    return JsonResponse(responce)

def orderhistory(request):
    lid=request.POST.get('lid')
    u=User.objects.get(login_id=lid)
    o=Buy.objects.filter(user_id=u.id)
    l=o.values_list('id', flat=True)
    print(o)
    data=[]
    for i in o:
        bd=BuyDetail.objects.filter(buy_id=i.id)
        print(bd)
        pd=[]
        for b in bd:
            pd.append(b.product.product)
        data.append({
            'date':i.date,
            'total':i.tamount,
            'products_bought':pd,
        })
    responce={
        'data':data,
    }
    return JsonResponse(responce)

# def verify(request,id):
#     a=TimeAllocate.objects.get(id=id)
#     sid=request.session['sid']
#     a.status='verified by shopkeeper'
#     a.save()
#     b=Buy.objects.get(user_id=a.user_id, status='Payement Done')
#     b.status = 'Purchase Scheduled'
#     c=BuyDetail.objects.filter(buy_id=b.id)
#     d=c.values_list('id', flat=True)
#     f=Stock.objects.get(shop_id=sid)
#     for i in d:
#         g=BuyDetail.objects.get(product_id=i)
#         q=g.quantity
#         e=StockDetail.objects.get(product_id=i, stock_id=f.id)
#         e.kiloorlitter-=q
#         e.save()
#     return HttpResponse("<script>alert('Time Slot verified');window.location='/sktime';</script>")
