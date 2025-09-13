from django.contrib import admin
from django.urls import path
from . import views
urlpatterns = [
    path('', views.home),
    #ADMIN MODULE

    path('ahome',views.ahome),
    path('gshome',views.gshome),
    path('skhome',views.skhome),
    path('login',views.login, name='login'),
    path('rtype',views.rtype),
    path('gs',views.gs),
    path('products',views.products),
    path('pedit/<id>',views.pedit),
    path('pdelete/<id>',views.pdelete),
    path('rtdelete/<id>',views.rtdelete),
    path('gsdelete/<id>',views.gsdelete),
    path('rtedit/<id>',views.rtedit),
    path('gsedit/<id>',views.gsedit),
    path('request',views.request),
    path('asd/<id>',views.asd),
    path('aud/<id>',views.aud),
    path('feedback',views.feedback),

#GS
    path('req',views.req),
    path('pt',views.pt),
    path('ptedit/<id>',views.ptedit),
    path('ptdelete/<id>',views.ptdelete),
    path('vsk',views.vsk),
    path('vsd/<id>',views.vsd),
    path('notification',views.notification),
    path('ud/<id>',views.ud),



#SK
    path('reg',views.reg, name='reg'),
    path('prt',views.prt),
    path('skstock',views.skstock),
    path('stdelete/<id>',views.stdelete),
    path('sktime',views.sktime),
    path('skrating',views.skrating),
    path('rc',views.rc),
    path('verify/<int:product_id>/<int:quantity>/<int:slot_id>/<int:tid>/', views.verify),
    path('viewslotproducts/<id>',views.viewslotproducts),



    path('api/loginuser',views.loginuser, name="loginuser"),
    path('api/userregister',views.reguser, name="reguser"),
    path('api/userfeedback',views.userfeedback, name="userfeedback"),
    path('api/view_feedback',views.view_feedback,name="view_feedback"),
    path('api/req',views.view_req,name="view_req"),
    path('api/rstatus',views.rstatus,name="rstatus"),
    path('api/rdetails',views.rdetails,name="rdetails"),
    path('api/pdetails',views.pdetails,name="pdetails"),
    path('api/notifications',views.notifications,name="notifications"),
    path('api/usershops',views.usershops,name="usershops"),
    path('api/userslot',views.userslot,name="userslot"),
    path('api/cart',views.cart,name="cart"),
    path('api/userviewcart',views.userviewcart,name="userviewcart"),
    path('api/rate',views.rate,name="rate"),
    path('api/payment',views.payment,name="payment"),
    path('api/viewrate',views.viewrate,name="viewrate"),
    path('api/slothistory',views.slothistory,name="slothistory"),
    path('api/orderhistory',views.orderhistory,name="orderhistory"),



    # URL pattern example
    path('verify/<int:product_id>/<int:quantity>/<int:slot_id>/<tid>', views.verify),

]
