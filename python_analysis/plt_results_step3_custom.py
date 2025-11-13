import matplotlib
matplotlib.use('Agg')  # Use non-interactive backend
import seaborn as sns
import pandas as pd
import matplotlib.pyplot as plt
import numpy as np
import os
import shutil

# Features to plot
feature_columns = ['counts_r', 'counts_g', 'counts_rg', 'volume_fraction', 'foci_volume', 'correlation',
                   'correlation_spearman', 'percentile99_r', 'percentile99_g', 'median_r', 'median_g']

data_path = r"D:\martin_urgent\URGENT_Naoparticle Manuscript Toufar\URGENT_Naoparticle Manuscript Toufar" + '_tmp_results'
df = pd.read_excel(data_path + '/results.xlsx')
results_path = f"{data_path}/boxplot_custom_results"
shutil.rmtree(results_path)
os.makedirs(results_path, exist_ok=True)

# Convert time to string for better grouping
df['time_str'] = df['time'].apply(lambda x: f'{x}h' if x >= 0 else 'nonIR')

def plot_xrays(df_xrays, feature):
    """
    Plot X-rays data with custom ordering:
    1. Non-IR, No-AuNPs (control)
    2. Gap
    3-6. 2 Gy X-Ray, No-AuNPs (0.5h, 4h, 8h, 24h)
    7. Gap
    8-11. 2 Gy X-Ray, 5-nm AuNPs (0.5h, 4h, 8h, 24h)
    12. Gap
    13-16. 4 Gy X-Ray, No-AuNPs (0.5h, 4h, 8h, 24h)
    17. Gap
    18-21. 4 Gy X-Ray, 5-nm AuNPs (0.5h, 4h, 8h, 24h)
    """
    
    # Define the groups and their data
    groups_data = []
    groups_labels = []
    groups_positions = []
    time_values = []  # Track time for each box for color gradient
    group_types = []  # Track group type (control, noNPs, AuNPs)
    
    # 1. Non-IR, No-AuNPs (control)
    control = df_xrays[(df_xrays['gy'] == 'nonIR') & (df_xrays['nps'] == 'X-rays')]
    if len(control) > 0:
        groups_data.append(control[feature].values)
        groups_labels.append('Non-IR\nNo-AuNPs')
        groups_positions.append(0)
        time_values.append(-1)  # Special value for control
        group_types.append('control')
    
    # 3-6. 2 Gy X-Ray, No-AuNPs
    pos = 2
    for time in [0.5, 4, 8, 24]:
        data_subset = df_xrays[(df_xrays['gy'] == '2') & (df_xrays['nps'] == 'noNPs') & (df_xrays['time'] == time)]
        if len(data_subset) > 0:
            groups_data.append(data_subset[feature].values)
            groups_labels.append(f'{time}h')
            groups_positions.append(pos)
            time_values.append(time)
            group_types.append('noNPs')
            pos += 1
    
    # 8-11. 2 Gy X-Ray, 5-nm AuNPs
    pos += 1  # Gap
    for time in [0.5, 4, 8, 24]:
        data_subset = df_xrays[(df_xrays['gy'] == '2') & (df_xrays['nps'] == 'Au-10Kopel_20ug') & (df_xrays['time'] == time)]
        if len(data_subset) > 0:
            groups_data.append(data_subset[feature].values)
            groups_labels.append(f'{time}h')
            groups_positions.append(pos)
            time_values.append(time)
            group_types.append('AuNPs')
            pos += 1
    
    # 13-16. 4 Gy X-Ray, No-AuNPs
    pos += 1  # Gap
    for time in [0.5, 4, 8, 24]:
        data_subset = df_xrays[(df_xrays['gy'] == '4') & (df_xrays['nps'] == 'noNPs') & (df_xrays['time'] == time)]
        if len(data_subset) > 0:
            groups_data.append(data_subset[feature].values)
            groups_labels.append(f'{time}h')
            groups_positions.append(pos)
            time_values.append(time)
            group_types.append('noNPs')
            pos += 1
    
    # 18-21. 4 Gy X-Ray, 5-nm AuNPs
    pos += 1  # Gap
    for time in [0.5, 4, 8, 24]:
        data_subset = df_xrays[(df_xrays['gy'] == '4') & (df_xrays['nps'] == 'Au-10Kopel_20ug') & (df_xrays['time'] == time)]
        if len(data_subset) > 0:
            groups_data.append(data_subset[feature].values)
            groups_labels.append(f'{time}h')
            groups_positions.append(pos)
            time_values.append(time)
            group_types.append('AuNPs')
            pos += 1
    
    # Create the plot
    fig, ax = plt.subplots(figsize=(14, 8))
    
    # Create boxplots with black median lines and visible whiskers
    bp = ax.boxplot(groups_data, positions=groups_positions, widths=0.6, 
                     patch_artist=True, showfliers=False,
                     medianprops=dict(color='black', linewidth=2),
                     whiskerprops=dict(color='black', linewidth=1.5),
                     capprops=dict(color='black', linewidth=1.5),
                     boxprops=dict(linewidth=1.5))
    
    # Color the boxes with gradient based on time
    # Time gradient: 0.5h=dark, 24h=light/transparent
    time_points = [0.5, 4, 8, 24]
    for i, (patch, time, gtype) in enumerate(zip(bp['boxes'], time_values, group_types)):
        if gtype == 'control':
            patch.set_facecolor('lightgreen')
            patch.set_edgecolor('black')
            patch.set_alpha(0.7)
        else:
            # Calculate intensity based on time (0.5h=1.0 dark, 24h=0.3 light)
            if time in time_points:
                time_idx = time_points.index(time)
                alpha = 1.0 - (time_idx * 0.23)  # 1.0, 0.77, 0.54, 0.31
            else:
                alpha = 0.7
            
            if gtype == 'noNPs':
                patch.set_facecolor('royalblue')
            else:  # AuNPs
                patch.set_facecolor('coral')
            patch.set_edgecolor('black')
            patch.set_alpha(alpha)
    
    # Explicitly redraw whiskers, caps, and medians
    for whisker in bp['whiskers']:
        whisker.set_color('black')
        whisker.set_linewidth(1.5)
    for cap in bp['caps']:
        cap.set_color('black')
        cap.set_linewidth(1.5)
    for median in bp['medians']:
        median.set_color('black')
        median.set_linewidth(2)
    
    # Set x-axis labels
    ax.set_xticks(groups_positions)
    ax.set_xticklabels(groups_labels, rotation=0)
    
    # Add group labels with brackets
    y_range = ax.get_ylim()[1] - ax.get_ylim()[0]
    y_line = ax.get_ylim()[0] - y_range * 0.15
    y_text = y_line - y_range * 0.02  # Add small offset below line
    
    # 2 Gy No-AuNPs
    if len(groups_positions) > 1:
        x_start, x_end = 2, 5
        ax.plot([x_start, x_end], [y_line, y_line], 'k-', linewidth=2)
        ax.text((x_start + x_end) / 2, y_text, '2 Gy X-Ray, No-AuNPs', ha='center', va='top', 
                fontsize=10, fontweight='bold')
    
    # 2 Gy 5-nm AuNPs
    if len(groups_positions) > 5:
        x_start, x_end = 7, 10
        ax.plot([x_start, x_end], [y_line, y_line], 'k-', linewidth=2)
        ax.text((x_start + x_end) / 2, y_text, '2 Gy X-Ray, 5-nm AuNPs', ha='center', va='top', 
                fontsize=10, fontweight='bold')
    
    # 4 Gy No-AuNPs
    if len(groups_positions) > 9:
        x_start, x_end = 12, 15
        ax.plot([x_start, x_end], [y_line, y_line], 'k-', linewidth=2)
        ax.text((x_start + x_end) / 2, y_text, '4 Gy X-Ray, No-AuNPs', ha='center', va='top', 
                fontsize=10, fontweight='bold')
    
    # 4 Gy 5-nm AuNPs
    if len(groups_positions) > 13:
        x_start, x_end = 17, 20
        ax.plot([x_start, x_end], [y_line, y_line], 'k-', linewidth=2)
        ax.text((x_start + x_end) / 2, y_text, '4 Gy X-Ray, 5-nm AuNPs', ha='center', va='top', 
                fontsize=10, fontweight='bold')
    
    ax.set_ylabel(feature, fontsize=12)
    ax.set_title(f'X-rays: {feature}', fontsize=14, fontweight='bold')
    ax.grid(axis='y', alpha=0.3)
    
    plt.tight_layout()
    return fig


def plot_gamma_rays(df_gamma, feature, nps_type, concentration):
    """
    Plot gamma-rays data for specific nanoparticle type and concentration.
    Same structure as X-rays but with gamma-ray specific nanoparticles.
    """
    
    # Map nanoparticle names
    nps_map = {
        ('0.8nm', '0.4ug'): 'Au-c_Kopel 0,4ug',
        ('0.8nm', '20ug'): 'Au-c Kopel 20ug',
        ('5nm', '0.4ug'): 'Au-10 Kopel 0,4ug',
        ('5nm', '20ug'): 'Au-10 Kopel 20ug'
    }
    
    nps_name = nps_map.get((nps_type, concentration))
    if nps_name is None:
        return None
    
    # Pre-filter for this nanoparticle type to speed up
    df_nps = df_gamma[df_gamma['nps'] == nps_name].copy()
    
    groups_data = []
    groups_labels = []
    groups_positions = []
    time_values = []  # Track time for each box for color gradient
    
    # 1. Non-IR, No-AuNPs (control) - using the general gamma-rays control
    control = df_gamma[(df_gamma['gy'] == 'nonIR') & (df_gamma['nps'] == 'gamma-rays')]
    if len(control) > 0:
        groups_data.append(control[feature].values)
        groups_labels.append('Non-IR\nNo-AuNPs')
        groups_positions.append(0)
        time_values.append(-1)  # Special value for control
    
    # For gamma-rays, we have 1, 2, and 4 Gy doses
    doses = ['1', '2', '4']
    pos = 2
    
    for dose in doses:
        # No-AuNPs group (we don't have this explicitly, so skip)
        # Since gamma-rays data doesn't have explicit "noNPs" entries in the same way,
        # we'll just plot the nanoparticle data
        
        # With AuNPs
        for time in [0.5, 4, 8, 24]:
            data_subset = df_nps[(df_nps['gy'] == dose) & (df_nps['time'] == time)]
            if len(data_subset) > 0:
                groups_data.append(data_subset[feature].values)
                groups_labels.append(f'{time}h')
                groups_positions.append(pos)
                time_values.append(time)
                pos += 1
        
        pos += 1  # Gap between dose levels
    
    # Create the plot
    fig, ax = plt.subplots(figsize=(14, 8))
    
    # Create boxplots with black median lines and visible whiskers
    bp = ax.boxplot(groups_data, positions=groups_positions, widths=0.6, 
                     patch_artist=True, showfliers=False,
                     medianprops=dict(color='black', linewidth=2),
                     whiskerprops=dict(color='black', linewidth=1.5),
                     capprops=dict(color='black', linewidth=1.5),
                     boxprops=dict(linewidth=1.5))
    
    # Color the boxes with gradient based on time
    # Time gradient: 0.5h=dark, 24h=light/transparent
    time_points = [0.5, 4, 8, 24]
    for i, (patch, time) in enumerate(zip(bp['boxes'], time_values)):
        if time == -1:  # Control
            patch.set_facecolor('lightgreen')
            patch.set_edgecolor('black')
            patch.set_alpha(0.7)
        else:
            # Calculate intensity based on time (0.5h=1.0 dark, 24h=0.3 light)
            if time in time_points:
                time_idx = time_points.index(time)
                alpha = 1.0 - (time_idx * 0.23)  # 1.0, 0.77, 0.54, 0.31
            else:
                alpha = 0.7
            
            patch.set_facecolor('coral')
            patch.set_edgecolor('black')
            patch.set_alpha(alpha)
    
    # Explicitly redraw whiskers, caps, and medians
    for whisker in bp['whiskers']:
        whisker.set_color('black')
        whisker.set_linewidth(1.5)
    for cap in bp['caps']:
        cap.set_color('black')
        cap.set_linewidth(1.5)
    for median in bp['medians']:
        median.set_color('black')
        median.set_linewidth(2)
    
    # Set x-axis labels
    ax.set_xticks(groups_positions)
    ax.set_xticklabels(groups_labels, rotation=0)
    
    # Add group labels with brackets
    y_range = ax.get_ylim()[1] - ax.get_ylim()[0]
    y_line = ax.get_ylim()[0] - y_range * 0.15
    y_text = y_line - y_range * 0.02  # Add small offset below line
    
    # 1 Gy
    if len(groups_positions) > 1:
        x_start = 2
        x_end = 2 + 3  # 4 time points
        ax.plot([x_start, x_end], [y_line, y_line], 'k-', linewidth=2)
        ax.text((x_start + x_end) / 2, y_text, f'1 Gy Gamma, {nps_type} AuNPs', ha='center', va='top', 
                fontsize=10, fontweight='bold')
    
    # 2 Gy
    if len(groups_positions) > 5:
        x_start = 7
        x_end = 7 + 3
        ax.plot([x_start, x_end], [y_line, y_line], 'k-', linewidth=2)
        ax.text((x_start + x_end) / 2, y_text, f'2 Gy Gamma, {nps_type} AuNPs', ha='center', va='top', 
                fontsize=10, fontweight='bold')
    
    # 4 Gy
    if len(groups_positions) > 10:
        x_start = 12
        x_end = 12 + 3
        ax.plot([x_start, x_end], [y_line, y_line], 'k-', linewidth=2)
        ax.text((x_start + x_end) / 2, y_text, f'4 Gy Gamma, {nps_type} AuNPs', ha='center', va='top', 
                fontsize=10, fontweight='bold')
    
    ax.set_ylabel(feature, fontsize=12)
    ax.set_title(f'Gamma-rays ({nps_type} AuNPs, {concentration}): {feature}', fontsize=14, fontweight='bold')
    ax.grid(axis='y', alpha=0.3)
    
    plt.tight_layout()
    return fig, ax


# Generate plots
import os

for feature in feature_columns:
    print(f'Plotting {feature}...')
    
    # X-rays plot
    save_path = results_path + f'/boxplot_custom_{feature}_X-rays.png'
    if not os.path.exists(save_path):
        df_xrays = df[df['cell_type'] == 'X-rays']
        fig = plot_xrays(df_xrays, feature)
        fig.savefig(save_path, bbox_inches='tight', dpi=300)
        plt.close(fig)
        print(f'  Saved X-rays plot')
    else:
        print(f'  Skipped X-rays (already exists)')
    
    # Gamma-rays plots (4 combinations) - first pass to get common y limits
    df_gamma = df[df['cell_type'] == 'gamma-rays']
    nps_combinations = [('0.8nm', '0.4ug'), ('0.8nm', '20ug'), ('5nm', '0.4ug'), ('5nm', '20ug')]
    
    # Calculate y-limits across all nanoparticle combinations
    y_min_global = float('inf')
    y_max_global = float('-inf')
    
    for nps_type, concentration in nps_combinations:
        fig_temp, ax_temp = plot_gamma_rays(df_gamma, feature, nps_type, concentration)
        if fig_temp is not None:
            y_limits = ax_temp.get_ylim()
            y_min_global = min(y_min_global, y_limits[0])
            y_max_global = max(y_max_global, y_limits[1])
            plt.close(fig_temp)
    
    # Second pass: create plots with common y-limits
    for nps_type, concentration in nps_combinations:
        safe_name = f'{nps_type}_{concentration}'.replace('.', 'p')
        save_path = results_path + f'/boxplot_custom_{feature}_gamma-rays_{safe_name}.png'
        
        if not os.path.exists(save_path):
            fig, ax = plot_gamma_rays(df_gamma, feature, nps_type, concentration)
            if fig is not None:
                # Apply common y-limits
                ax.set_ylim(y_min_global, y_max_global)
                
                # Recalculate label positions with new y limits
                y_range = y_max_global - y_min_global
                y_line = y_min_global - y_range * 0.15
                y_text = y_line - y_range * 0.02
                
                # Update ONLY the horizontal bracket lines (not whiskers/caps/medians)
                # The bracket lines are the ones we manually added with ax.plot()
                # They should be the last 3 lines added (after all boxplot elements)
                all_lines = ax.lines
                # Find lines that span horizontally (bracket lines have same y values)
                for line in all_lines:
                    ydata = line.get_ydata()
                    # Bracket lines have 2 points with same y value and span multiple x positions
                    if len(ydata) == 2 and abs(ydata[0] - ydata[1]) < 1e-6:
                        xdata = line.get_xdata()
                        if abs(xdata[1] - xdata[0]) > 1:  # Spans multiple positions
                            line.set_ydata([y_line, y_line])
                
                for text in ax.texts:
                    text.set_y(y_text)
                
                fig.savefig(save_path, bbox_inches='tight', dpi=300)
                plt.close(fig)
                print(f'  Saved gamma-rays {safe_name}')
        else:
            print(f'  Skipped gamma-rays {safe_name} (already exists)')

print('Done!')
