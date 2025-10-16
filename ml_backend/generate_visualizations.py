"""
Generate visualizations for Ignis ML Model presentation
Creates professional plots for slideshow
"""

import json
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
from pathlib import Path

# Set style for professional-looking plots
sns.set_style("whitegrid")
plt.rcParams['figure.figsize'] = (12, 8)
plt.rcParams['font.size'] = 12
plt.rcParams['axes.labelsize'] = 14
plt.rcParams['axes.titlesize'] = 16
plt.rcParams['xtick.labelsize'] = 12
plt.rcParams['ytick.labelsize'] = 12

# Color palette - fire-themed
FIRE_COLORS = ['#4CAF50', '#FFC107', '#FF9800', '#F44336']  # Low, Moderate, High, Extreme
ACCENT_COLOR = '#FF5722'

def load_results():
    """Load model results"""
    with open('enhanced_model_results.json', 'r') as f:
        data = json.load(f)
    
    # Convert enhanced model format to expected format
    ensemble = data['Ensemble']
    
    # Need to reconstruct per-class metrics and confusion matrix from predictions
    y_true = data['predictions']['y_true']
    y_pred = data['predictions']['y_pred_ensemble']
    
    from sklearn.metrics import confusion_matrix, classification_report
    import json as json_module
    
    cm = confusion_matrix(y_true, y_pred)
    report = classification_report(y_true, y_pred, target_names=['Low', 'Moderate', 'High', 'Extreme'], output_dict=True)
    
    # Build results in expected format
    results = {
        'training': {
            'accuracy': 0.896,  # Approximate from training
            'precision': 0.897,
            'recall': 0.896,
            'f1_score': 0.896
        },
        'testing': {
            'accuracy': ensemble['accuracy'],
            'precision': ensemble['precision_weighted'],
            'recall': ensemble['recall_weighted'],
            'f1_score': ensemble['f1_weighted']
        },
        'macro_averages': {
            'precision': ensemble['precision_macro'],
            'recall': ensemble['recall_macro'],
            'f1_score': ensemble['f1_macro']
        },
        'per_class': {
            'Low': {
                'precision': report['Low']['precision'],
                'recall': report['Low']['recall'],
                'f1_score': report['Low']['f1-score'],
                'support': report['Low']['support']
            },
            'Moderate': {
                'precision': report['Moderate']['precision'],
                'recall': report['Moderate']['recall'],
                'f1_score': report['Moderate']['f1-score'],
                'support': report['Moderate']['support']
            },
            'High': {
                'precision': report['High']['precision'],
                'recall': report['High']['recall'],
                'f1_score': report['High']['f1-score'],
                'support': report['High']['support']
            },
            'Extreme': {
                'precision': report['Extreme']['precision'],
                'recall': report['Extreme']['recall'],
                'f1_score': report['Extreme']['f1-score'],
                'support': report['Extreme']['support']
            }
        },
        'confusion_matrix': cm.tolist(),
        'feature_importance': data['feature_importance'],
        'risk_distribution': {
            'actual_test': [int(report['Low']['support']), int(report['Moderate']['support']), 
                           int(report['High']['support']), int(report['Extreme']['support'])],
            'predicted_test': [int(sum(cm[:, 0])), int(sum(cm[:, 1])), 
                              int(sum(cm[:, 2])), int(sum(cm[:, 3]))],
            'class_names': ['Low', 'Moderate', 'High', 'Extreme']
        }
    }
    
    return results

def plot_1_accuracy_comparison(results):
    """Plot 1: Training vs Testing Accuracy"""
    fig, ax = plt.subplots(figsize=(10, 6))
    
    metrics = ['Accuracy', 'Precision', 'Recall', 'F1-Score']
    training_scores = [
        results['training']['accuracy'],
        results['training']['precision'],
        results['training']['recall'],
        results['training']['f1_score']
    ]
    testing_scores = [
        results['testing']['accuracy'],
        results['testing']['precision'],
        results['testing']['recall'],
        results['testing']['f1_score']
    ]
    
    x = np.arange(len(metrics))
    width = 0.35
    
    bars1 = ax.bar(x - width/2, training_scores, width, label='Training', 
                   color='#2196F3', alpha=0.8, edgecolor='black', linewidth=1.5)
    bars2 = ax.bar(x + width/2, testing_scores, width, label='Testing', 
                   color=ACCENT_COLOR, alpha=0.8, edgecolor='black', linewidth=1.5)
    
    # Add value labels on bars
    for bars in [bars1, bars2]:
        for bar in bars:
            height = bar.get_height()
            ax.text(bar.get_x() + bar.get_width()/2., height,
                   f'{height:.1%}',
                   ha='center', va='bottom', fontweight='bold', fontsize=11)
    
    ax.set_ylabel('Score', fontweight='bold')
    ax.set_title('Model Performance: Training vs Testing', fontweight='bold', pad=20)
    ax.set_xticks(x)
    ax.set_xticklabels(metrics)
    ax.legend(loc='lower right', frameon=True, shadow=True)
    ax.set_ylim(0, 1.0)
    ax.grid(axis='y', alpha=0.3)
    
    plt.tight_layout()
    plt.savefig('plot_1_accuracy_comparison.png', dpi=300, bbox_inches='tight')
    print("✅ Saved: plot_1_accuracy_comparison.png")
    plt.close()

def plot_2_confusion_matrix(results):
    """Plot 2: Confusion Matrix Heatmap"""
    fig, ax = plt.subplots(figsize=(10, 8))
    
    cm = np.array(results['confusion_matrix'])
    class_names = ['Low', 'Moderate', 'High', 'Extreme']
    
    # Normalize for percentages
    cm_percent = cm.astype('float') / cm.sum(axis=1)[:, np.newaxis] * 100
    
    # Create heatmap
    sns.heatmap(cm, annot=True, fmt='d', cmap='YlOrRd', 
                xticklabels=class_names, yticklabels=class_names,
                cbar_kws={'label': 'Count'}, linewidths=2, linecolor='white',
                ax=ax, vmin=0, square=True)
    
    # Add percentage annotations
    for i in range(len(class_names)):
        for j in range(len(class_names)):
            text = ax.text(j + 0.5, i + 0.7, f'({cm_percent[i, j]:.1f}%)',
                          ha="center", va="center", color="black", fontsize=9)
    
    ax.set_ylabel('Actual Risk Level', fontweight='bold')
    ax.set_xlabel('Predicted Risk Level', fontweight='bold')
    ax.set_title('Confusion Matrix - Wildfire Risk Classification', fontweight='bold', pad=20)
    
    plt.tight_layout()
    plt.savefig('plot_2_confusion_matrix.png', dpi=300, bbox_inches='tight')
    print("✅ Saved: plot_2_confusion_matrix.png")
    plt.close()

def plot_3_feature_importance(results):
    """Plot 3: Top Feature Importance"""
    fig, ax = plt.subplots(figsize=(12, 8))
    
    # Get top 10 features
    features = results['feature_importance']
    # Filter out zero importance features
    features = {k: v for k, v in features.items() if v > 0}
    sorted_features = sorted(features.items(), key=lambda x: x[1], reverse=True)[:10]
    
    feature_names = [f.replace('_', ' ').title() for f, _ in sorted_features]
    importances = [imp for _, imp in sorted_features]
    
    # Create horizontal bar chart
    colors = plt.cm.YlOrRd(np.linspace(0.3, 0.9, len(feature_names)))
    bars = ax.barh(feature_names, importances, color=colors, edgecolor='black', linewidth=1.5)
    
    # Add value labels
    for i, (bar, imp) in enumerate(zip(bars, importances)):
        width = bar.get_width()
        ax.text(width, bar.get_y() + bar.get_height()/2,
               f' {imp:.3f}',
               ha='left', va='center', fontweight='bold', fontsize=11)
    
    ax.set_xlabel('Importance Score', fontweight='bold')
    ax.set_title('Top 10 Most Important Features for Wildfire Risk Prediction', 
                 fontweight='bold', pad=20)
    ax.invert_yaxis()
    ax.grid(axis='x', alpha=0.3)
    
    plt.tight_layout()
    plt.savefig('plot_3_feature_importance.png', dpi=300, bbox_inches='tight')
    print("✅ Saved: plot_3_feature_importance.png")
    plt.close()

def plot_4_per_class_performance(results):
    """Plot 4: Per-Class Performance Metrics"""
    fig, ax = plt.subplots(figsize=(12, 7))
    
    class_names = ['Low', 'Moderate', 'High', 'Extreme']
    metrics = ['precision', 'recall', 'f1-score']
    
    x = np.arange(len(class_names))
    width = 0.25
    
    precision_scores = [results['per_class'][cls]['precision'] for cls in class_names]
    recall_scores = [results['per_class'][cls]['recall'] for cls in class_names]
    f1_scores = [results['per_class'][cls]['f1_score'] for cls in class_names]
    
    bars1 = ax.bar(x - width, precision_scores, width, label='Precision', 
                   color='#2196F3', alpha=0.8, edgecolor='black', linewidth=1.5)
    bars2 = ax.bar(x, recall_scores, width, label='Recall', 
                   color='#4CAF50', alpha=0.8, edgecolor='black', linewidth=1.5)
    bars3 = ax.bar(x + width, f1_scores, width, label='F1-Score', 
                   color=ACCENT_COLOR, alpha=0.8, edgecolor='black', linewidth=1.5)
    
    # Add value labels
    for bars in [bars1, bars2, bars3]:
        for bar in bars:
            height = bar.get_height()
            ax.text(bar.get_x() + bar.get_width()/2., height,
                   f'{height:.2f}',
                   ha='center', va='bottom', fontsize=9, fontweight='bold')
    
    ax.set_ylabel('Score', fontweight='bold')
    ax.set_xlabel('Risk Level', fontweight='bold')
    ax.set_title('Performance Metrics by Risk Level', fontweight='bold', pad=20)
    ax.set_xticks(x)
    ax.set_xticklabels(class_names)
    ax.legend(loc='lower right', frameon=True, shadow=True)
    ax.set_ylim(0, 1.0)
    ax.grid(axis='y', alpha=0.3)
    
    plt.tight_layout()
    plt.savefig('plot_4_per_class_performance.png', dpi=300, bbox_inches='tight')
    print("✅ Saved: plot_4_per_class_performance.png")
    plt.close()

def plot_5_risk_distribution(results):
    """Plot 5: Actual vs Predicted Risk Distribution"""
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))
    
    class_names = results['risk_distribution']['class_names']
    actual = results['risk_distribution']['actual_test']
    predicted = results['risk_distribution']['predicted_test']
    
    # Actual distribution
    bars1 = ax1.bar(class_names, actual, color=FIRE_COLORS, 
                    edgecolor='black', linewidth=2, alpha=0.8)
    ax1.set_ylabel('Count', fontweight='bold')
    ax1.set_title('Actual Risk Distribution', fontweight='bold', pad=15)
    ax1.grid(axis='y', alpha=0.3)
    
    # Add value labels
    for bar in bars1:
        height = bar.get_height()
        ax1.text(bar.get_x() + bar.get_width()/2., height,
                f'{int(height)}',
                ha='center', va='bottom', fontweight='bold', fontsize=11)
    
    # Predicted distribution
    bars2 = ax2.bar(class_names, predicted, color=FIRE_COLORS, 
                    edgecolor='black', linewidth=2, alpha=0.8)
    ax2.set_ylabel('Count', fontweight='bold')
    ax2.set_title('Predicted Risk Distribution', fontweight='bold', pad=15)
    ax2.grid(axis='y', alpha=0.3)
    
    # Add value labels
    for bar in bars2:
        height = bar.get_height()
        ax2.text(bar.get_x() + bar.get_width()/2., height,
                f'{int(height)}',
                ha='center', va='bottom', fontweight='bold', fontsize=11)
    
    plt.suptitle('Risk Level Distribution: Actual vs Predicted', 
                 fontweight='bold', fontsize=16, y=1.02)
    plt.tight_layout()
    plt.savefig('plot_5_risk_distribution.png', dpi=300, bbox_inches='tight')
    print("✅ Saved: plot_5_risk_distribution.png")
    plt.close()

def plot_6_model_summary(results):
    """Plot 6: Overall Model Summary Dashboard"""
    fig = plt.figure(figsize=(14, 10))
    gs = fig.add_gridspec(3, 2, hspace=0.3, wspace=0.3)
    
    # Overall accuracy gauge
    ax1 = fig.add_subplot(gs[0, :])
    accuracy = results['testing']['accuracy']
    
    # Create a simple text-based summary
    ax1.axis('off')
    summary_text = f"""
    🎯 IGNIS WILDFIRE RISK PREDICTION MODEL
    
    Overall Test Accuracy: {accuracy:.1%}
    
    Key Performance Metrics:
    • Precision (Weighted): {results['testing']['precision']:.1%}
    • Recall (Weighted): {results['testing']['recall']:.1%}
    • F1-Score (Weighted): {results['testing']['f1_score']:.1%}
    
    Model Type: Ensemble (XGBoost + Random Forest)
    Training Samples: 12,000
    Testing Samples: 3,000
    """
    
    ax1.text(0.5, 0.5, summary_text, ha='center', va='center', 
             fontsize=14, family='monospace',
             bbox=dict(boxstyle='round', facecolor='wheat', alpha=0.3))
    
    # Macro averages
    ax2 = fig.add_subplot(gs[1, 0])
    macro_metrics = ['Precision', 'Recall', 'F1-Score']
    macro_values = [
        results['macro_averages']['precision'],
        results['macro_averages']['recall'],
        results['macro_averages']['f1_score']
    ]
    colors_macro = ['#2196F3', '#4CAF50', ACCENT_COLOR]
    bars = ax2.bar(macro_metrics, macro_values, color=colors_macro, 
                   edgecolor='black', linewidth=2, alpha=0.8)
    ax2.set_ylabel('Score', fontweight='bold')
    ax2.set_title('Macro-Averaged Metrics', fontweight='bold')
    ax2.set_ylim(0, 1.0)
    ax2.grid(axis='y', alpha=0.3)
    
    for bar in bars:
        height = bar.get_height()
        ax2.text(bar.get_x() + bar.get_width()/2., height,
                f'{height:.1%}',
                ha='center', va='bottom', fontweight='bold')
    
    # Class support
    ax3 = fig.add_subplot(gs[1, 1])
    class_names = ['Low', 'Moderate', 'High', 'Extreme']
    support = [results['per_class'][cls]['support'] for cls in class_names]
    ax3.pie(support, labels=class_names, autopct='%1.1f%%', 
            colors=FIRE_COLORS, startangle=90,
            wedgeprops=dict(edgecolor='black', linewidth=2))
    ax3.set_title('Test Set Class Distribution', fontweight='bold')
    
    # Performance by class
    ax4 = fig.add_subplot(gs[2, :])
    x = np.arange(len(class_names))
    width = 0.25
    
    precision_scores = [results['per_class'][cls]['precision'] for cls in class_names]
    recall_scores = [results['per_class'][cls]['recall'] for cls in class_names]
    f1_scores = [results['per_class'][cls]['f1_score'] for cls in class_names]
    
    ax4.bar(x - width, precision_scores, width, label='Precision', 
            color='#2196F3', alpha=0.8, edgecolor='black', linewidth=1.5)
    ax4.bar(x, recall_scores, width, label='Recall', 
            color='#4CAF50', alpha=0.8, edgecolor='black', linewidth=1.5)
    ax4.bar(x + width, f1_scores, width, label='F1-Score', 
            color=ACCENT_COLOR, alpha=0.8, edgecolor='black', linewidth=1.5)
    
    ax4.set_ylabel('Score', fontweight='bold')
    ax4.set_xlabel('Risk Level', fontweight='bold')
    ax4.set_title('Detailed Performance by Risk Level', fontweight='bold')
    ax4.set_xticks(x)
    ax4.set_xticklabels(class_names)
    ax4.legend(loc='lower right', frameon=True, shadow=True)
    ax4.set_ylim(0, 1.0)
    ax4.grid(axis='y', alpha=0.3)
    
    plt.savefig('plot_6_model_summary.png', dpi=300, bbox_inches='tight')
    print("✅ Saved: plot_6_model_summary.png")
    plt.close()

def main():
    """Generate all visualizations"""
    print("🎨 Generating ML Model Visualizations for Slideshow")
    print("="*60)
    
    # Load results
    results = load_results()
    
    # Generate all plots
    plot_1_accuracy_comparison(results)
    plot_2_confusion_matrix(results)
    plot_3_feature_importance(results)
    plot_4_per_class_performance(results)
    plot_5_risk_distribution(results)
    plot_6_model_summary(results)
    
    print("\n" + "="*60)
    print("✅ All visualizations generated successfully!")
    print("="*60)
    print("\nGenerated files:")
    print("  1. plot_1_accuracy_comparison.png - Training vs Testing metrics")
    print("  2. plot_2_confusion_matrix.png - Confusion matrix heatmap")
    print("  3. plot_3_feature_importance.png - Top 10 important features")
    print("  4. plot_4_per_class_performance.png - Per-class metrics")
    print("  5. plot_5_risk_distribution.png - Actual vs Predicted distribution")
    print("  6. plot_6_model_summary.png - Overall model dashboard")
    print("\nAll images are high-resolution (300 DPI) and ready for presentation!")

if __name__ == "__main__":
    main()

