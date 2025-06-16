from django.views.generic import TemplateView, ListView, DetailView
from .models import Post, Comment
from rest_framework import generics, permissions
from .serializers import CommentSerializer

class HomePageView(TemplateView):
    template_name = 'home.html'
    
class AboutPageView(TemplateView):
    template_name = 'about.html'

class BlogListView(ListView):
    model = Post
    template_name = 'blog.html'
    
class BlogDetailView(DetailView):
    model = Post
    template_name = 'blog_detail.html'

class CommentListCreateAPIView(generics.ListCreateAPIView):
    serializer_class = CommentSerializer
    permission_classes = [permissions.IsAuthenticatedOrReadOnly]

    def get_queryset(self):
        post_id = self.kwargs['pk']
        return Comment.objects.filter(post_id=post_id).order_by('-created_at')

    def perform_create(self, serializer):
        post_id = self.kwargs['pk']
        serializer.save(post_id=post_id, author=self.request.user)
        
    
