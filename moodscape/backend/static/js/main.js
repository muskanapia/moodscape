// MoodScape - Main JavaScript File
// Academic Project for CSE370 (Database Systems)

// Utility functions for admin actions
function banUser(userId) {
    if (confirm('Are you sure you want to ban this user?')) {
        // In a real application, this would make an AJAX call
        alert('User banned successfully (demo mode)');
    }
}

function unbanUser(userId) {
    if (confirm('Are you sure you want to unban this user?')) {
        // In a real application, this would make an AJAX call
        alert('User unbanned successfully (demo mode)');
    }
}

function approveRequest(requestId) {
    if (confirm('Are you sure you want to approve this request?')) {
        // In a real application, this would make an AJAX call
        alert('Request approved successfully (demo mode)');
    }
}

function rejectRequest(requestId) {
    if (confirm('Are you sure you want to reject this request?')) {
        // In a real application, this would make an AJAX call
        alert('Request rejected successfully (demo mode)');
    }
}

// Form validation
document.addEventListener('DOMContentLoaded', function() {
    // Auto-hide alerts after 5 seconds
    const alerts = document.querySelectorAll('.alert');
    alerts.forEach(function(alert) {
        setTimeout(function() {
            alert.style.opacity = '0';
            alert.style.transition = 'opacity 0.5s';
            setTimeout(function() {
                alert.remove();
            }, 500);
        }, 5000);
    });
    
    // Add form validation
    const forms = document.querySelectorAll('form');
    forms.forEach(function(form) {
        form.addEventListener('submit', function(e) {
            // Basic validation for rating
            const ratingSelect = form.querySelector('select[name="rating"]');
            if (ratingSelect && !ratingSelect.value) {
                e.preventDefault();
                alert('Please select a rating');
                return;
            }
            
            // Basic validation for mood tags in review form
            const moodCheckboxes = form.querySelectorAll('input[name="moods"]');
            if (moodCheckboxes.length > 0) {
                const checkedMoods = form.querySelectorAll('input[name="moods"]:checked');
                if (checkedMoods.length === 0) {
                    e.preventDefault();
                    if (!confirm('No mood tags selected. Continue without mood tags?')) {
                        return;
                    }
                }
            }
        });
    });
});

// Search form enhancement
document.addEventListener('DOMContentLoaded', function() {
    const searchForm = document.querySelector('.search-form form');
    if (searchForm) {
        // Add real-time search (debounced)
        let searchTimeout;
        const inputs = searchForm.querySelectorAll('input, select');
        
        inputs.forEach(function(input) {
            input.addEventListener('change', function() {
                clearTimeout(searchTimeout);
                searchTimeout = setTimeout(function() {
                    // Auto-submit form on input change (optional)
                    // searchForm.submit();
                }, 1000);
            });
        });
    }
});

// Movie card interactions
document.addEventListener('DOMContentLoaded', function() {
    const movieCards = document.querySelectorAll('.movie-card');
    
    movieCards.forEach(function(card) {
        card.addEventListener('mouseenter', function() {
            this.style.transform = 'translateY(-4px)';
        });
        
        card.addEventListener('mouseleave', function() {
            this.style.transform = 'translateY(0)';
        });
    });
});

// Chart.js configuration for mood distribution
document.addEventListener('DOMContentLoaded', function() {
    // Global Chart.js configuration
    if (typeof Chart !== 'undefined') {
        Chart.defaults.font.family = "'Segoe UI', Tahoma, Geneva, Verdana, sans-serif";
        Chart.defaults.font.size = 12;
        
        // Color palette for mood charts
        window.moodColors = [
            '#FF6384', '#36A2EB', '#FFCE56', '#4BC0C0', '#9966FF',
            '#FF9F40', '#FF6384', '#C9CBCF', '#4BC0C0', '#FF6384'
        ];
    }
});

// Utility function to format dates
function formatDate(dateString) {
    const date = new Date(dateString);
    return date.toLocaleDateString('en-US', {
        year: 'numeric',
        month: 'long',
        day: 'numeric'
    });
}

// Utility function to get mood color
function getMoodColor(moodName) {
    const moodColors = {
        'Happy': '#FFD700',
        'Sad': '#4169E1',
        'Inspired': '#FF6347',
        'Tense': '#DC143C',
        'Emotional': '#9370DB',
        'Excited': '#FF69B4',
        'Relaxed': '#20B2AA',
        'Confused': '#808080',
        'Angry': '#8B0000',
        'Nostalgic': '#DDA0DD'
    };
    return moodColors[moodName] || '#95a5a6';
}

// Export functions for use in other scripts
if (typeof module !== 'undefined' && module.exports) {
    module.exports = {
        banUser,
        unbanUser,
        approveRequest,
        rejectRequest,
        formatDate,
        getMoodColor
    };
}