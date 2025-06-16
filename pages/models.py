from django.db import models

class Post(models.Model):
    title = models.CharField(max_length=200)
    author = models.ForeignKey('auth.User', on_delete=models.CASCADE)
    body = models.TextField()

    def __str__(self):
        return self.title

class Comment(models.Model):
    post = models.ForeignKey(Post, on_delete=models.CASCADE, related_name='comments')
    author = models.ForeignKey('auth.User', on_delete=models.CASCADE)
    created_at= models.DateTimeField(auto_now_add=True)
    body = models.TextField()

    def __str__(self):
        return f"{self.author} - {self.created_at.strftime('%Y-%m-%d %H:%M:%S')} - {self.body}"
