document.getElementById('contactForm').addEventListener('submit', async function(event) {
    event.preventDefault();

    const formData = new FormData(this);
    const data = {
        name: formData.get('name'),
        email: formData.get('email'),
        message: formData.get('message')
    };

    try {
        const response = await fetch('/submit', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify(data)
        });

        if (response.ok) {
            alert('Form submitted successfully!');
            this.reset();
        } else {
            alert('Form submission failed.');
        }
    } catch (error) {
        console.error('Error:', error);
        alert('An error occurred.');
    }
});
