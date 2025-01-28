from django.urls import path, include

from rest_framework.routers import DefaultRouter

from profiles_api import views

router=DefaultRouter()

#register our viewset to router
router.register('hello-viewset', views.HelloViewSet, base_name='hello-viewset')
#no need of base_name as we have given queryset in UserProfileViewSet so django can confiqure out the name from the model that is assigned to it
router.register('profile', views.UserProfileViewSet)


urlpatterns = [

path('hello-view/', views.HelloApiView.as_view()),

# includes all the URLs generated by the router
path('', include(router.urls))

]
