from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status   #gives status codes WITH A HANDY RESPONSE

from profiles_api import serializers

class HelloApiView(APIView):
    """Test API View"""

    serializer_class= serializers.HelloSerializer

# to retrieve an object or list of objects
    def get(self, request, format=None):
            """Returns a list of APIView features"""
            an_apiview=[
             'Users HTTP methods as function (get, post, patch, put, delete)',
             'Is similar to traditional Django View',
             'Gives you most control over your application logic',
             'Is mapped manually to URLs',
            ]

            return Response({'message':'Hello!', 'an_apiview':an_apiview})

    def post(self, request):
            """Create a hello message with our name"""
            serializer = self.serializer_class(data=request.data)

            if serializer.is_valid():
                    name = serializer.validated_data.get('name')
                    message=f'Hello {name}'
                    return Response({'message':message})
            else:
                return Response(
                serializer.errors,
                status=status.HTTP_400_BAD_REQUEST
                    )

#to update an object
    def put(self, request, pk=None):
        """Handle updating object"""
        return Response ({'method': 'PUT'})

#to partially update an object
    def patch(self, request, pk=None):
        """Handle partial update of an object"""
        return Response ({'method': 'PATCH'})


#to delete
    def delete(self, request, pk=None):
        """Delete an object"""
        return Response ({'method': 'DELETE'})
