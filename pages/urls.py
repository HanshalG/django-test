from django.urls import path
from .views import (
    HomePageView, 
    AboutPageView, 
    BlogListView, 
    BlogDetailView, 
    CommentListCreateAPIView,
    CounterView
)

urlpatterns = [
    path('', HomePageView.as_view(), name='home'),
    path('about/', AboutPageView.as_view(), name='about'),
    path('blog/', BlogListView.as_view(), name='blog'),
    path('post/<int:pk>/', BlogDetailView.as_view(), name='post_detail'),
    path('post/<int:pk>/comments/', CommentListCreateAPIView.as_view(), name='post-comments'),
    path('counter/', CounterView.as_view(), name='counter'),
]
