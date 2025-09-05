from django.db import models


class Login(models.Model):
        username = models.CharField(max_length=100)
        password = models.CharField(max_length=100) 
        usertype = models.CharField(max_length=100)

class Type(models.Model):
    name = models.CharField(max_length=100, unique=True)
    details = models.CharField(max_length=100)

class GovtStaff(models.Model):
    login = models.OneToOneField(Login, on_delete=models.CASCADE)
    fname = models.CharField(max_length=100)
    lname = models.CharField(max_length=100)
    place = models.CharField(max_length=100)
    phone = models.CharField(max_length=100)
    email = models.CharField(max_length=100)
    designation = models.CharField(max_length=100)


class Shop(models.Model):
    login = models.OneToOneField(Login, on_delete=models.CASCADE)
    fname = models.CharField(max_length=100)
    lname = models.CharField(max_length=100)
    shop = models.CharField(max_length=100)
    place = models.CharField(max_length=100)
    phone = models.CharField(max_length=100)
    email = models.CharField(max_length=100)

class User(models.Model):
    login = models.OneToOneField(Login, on_delete=models.CASCADE)
    fname = models.CharField(max_length=100)
    lname = models.CharField(max_length=100)
    hname = models.CharField(max_length=100)
    ward = models.CharField(max_length=100)
    hno = models.CharField(max_length=100)
    place = models.CharField(max_length=100)
    age = models.PositiveSmallIntegerField()
    gender = models.CharField(max_length=100)
    phone = models.CharField(max_length=100)
    email = models.CharField(max_length=100)
    designation = models.CharField(max_length=100, blank=True)

class Product(models.Model):
    product = models.CharField(max_length=100)
    details = models.CharField(max_length=100)
    amount = models.DecimalField(max_digits=10, decimal_places=2)


class ProductType(models.Model):
    type = models.OneToOneField(Type, on_delete=models.CASCADE)
    product = models.OneToOneField(Product, on_delete=models.CASCADE)
    kiloorlitter = models.CharField(max_length=100)
    forthemonth = models.IntegerField()

class Stock(models.Model):
    shop = models.OneToOneField(Shop, on_delete=models.CASCADE)
    date = models.DateTimeField()

class StockDetail(models.Model):
    stock = models.OneToOneField(Stock, on_delete=models.CASCADE)
    product = models.OneToOneField(Product, on_delete=models.CASCADE)
    kiloorlitter = models.CharField(max_length=100)

class Buy(models.Model):
    user = models.OneToOneField(User, on_delete=models.CASCADE)
    tamount = models.DecimalField(max_digits=10, decimal_places=2)
    date = models.DateTimeField(auto_now_add=True)
    status = models.CharField(max_length=100)

class BuyDetail(models.Model):
    buy = models.OneToOneField(Buy, on_delete=models.CASCADE)
    product = models.OneToOneField(Product, on_delete=models.CASCADE)
    quantity = models.PositiveIntegerField()
    amount = models.DecimalField(max_digits=10, decimal_places=2)

class RequestRationCard(models.Model):
    user = models.OneToOneField(User, on_delete=models.CASCADE)
    status = models.CharField(max_length=100)

class RequestDetail(models.Model):
    request = models.OneToOneField(RequestRationCard, on_delete=models.CASCADE)
    name = models.CharField(max_length=100)
    relation = models.CharField(max_length=100)
    designation = models.CharField(max_length=100, blank=True)

class StaffDetail(models.Model):
    request = models.OneToOneField(RequestRationCard, on_delete=models.CASCADE)
    detail = models.TextField()
    status = models.CharField(max_length=100)
    staff_id=models.OneToOneField(GovtStaff, on_delete=models.CASCADE)

class TimeAllocate(models.Model):

    user = models.OneToOneField(User, on_delete=models.CASCADE)
    date = models.DateTimeField()
    time = models.TimeField()
    shop = models.OneToOneField(Shop, on_delete=models.CASCADE)
    status = models.CharField(max_length=100)

class Notification(models.Model):
    notification = models.CharField(max_length=250)
    details = models.TextField(blank=True)
    date = models.DateTimeField(auto_now_add=True)

class RationCard(models.Model):
    cardnumber = models.CharField(max_length=50, unique=True)
    request = models.OneToOneField(RequestRationCard, on_delete=models.CASCADE)
    date = models.DateTimeField()
    type=models.OneToOneField(Type,on_delete=models.CASCADE)

class Rating(models.Model):
    shop = models.OneToOneField(Shop, on_delete=models.CASCADE)
    user = models.OneToOneField(User, on_delete=models.CASCADE)
    rated = models.PositiveSmallIntegerField()  # 1–5
    date = models.DateTimeField(auto_now_add=True)

class Payment(models.Model):
    buy = models.OneToOneField(Buy, on_delete=models.CASCADE)
    amount = models.DecimalField(max_digits=10, decimal_places=2)
    date = models.DateTimeField(auto_now_add=True)

class Feedback(models.Model):
    user = models.OneToOneField(User, on_delete=models.CASCADE)
    feedback = models.TextField()
    date = models.DateTimeField(auto_now_add=True)
