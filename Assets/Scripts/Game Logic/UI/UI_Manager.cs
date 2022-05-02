using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class UI_Manager : MonoBehaviour
{
    [SerializeField]
    private GameObject m_Crosshair;

    [SerializeField]
    private Transform m_arrowSpawnPoint;

    [SerializeField]
    private LineRenderer m_CircleRenderer;

    [SerializeField]
    private Slider m_HealthBar;

    private static Vector3 m_centerOfScreen = new Vector3(0.5f, 0.5f, 0f);

    private RaycastHit m_rayCastHit;

    private float m_rayLength = 100f;

    private float m_alphaCircle;

    private Color m_color;

    private Gradient m_gradient;

    private void Update()
    {
        Ray ray = Camera.main.ViewportPointToRay(new Vector3(0.5F, 0.5F, 0));
        RaycastHit hit;

        if (Physics.Raycast(ray, out hit))
        {
            if (hit.transform.gameObject.tag == "Enemy")
            {
                ChangeColorCrosshair(Color.red);
            }
            else
            {
                ChangeColorCrosshair(Color.white);
            }
        } else
        {
            ChangeColorCrosshair(Color.white);
        }
    }

    /// <summary>
    /// set the alpha of the circle
    /// </summary>
    /// <param name="alpha"></param>
    public void SetAlphaCirlce(float alpha)
    {
        m_alphaCircle = alpha;
    }


    /// <summary>
    /// change the color of the crosshair if an enemy is in sight
    /// </summary>
    /// <param name="color"></param>
    public void ChangeColorCrosshair(Color color)
    {
        Image[] l_imageList = this.GetComponentsInChildren<Image>();

        for (int i = 0; i < l_imageList.Length; i++)
        {
            if(l_imageList[i].name == "Crosshair")
            {
                l_imageList[i].color = color;
            }
        }
    }

    /// <summary>
    /// shows the hud when shooting the arrow
    /// </summary>
    /// <param name="show"></param>
    public void ShowHud(bool show)
    {

        if (show)
        {
            m_CircleRenderer.enabled = true;
        } else
        {
            m_CircleRenderer.enabled = false;
        }
        
    }

    /// <summary>
    /// Draws the reticle cirle using line renderer
    /// </summary>
    /// <param name="steps"></param>
    /// <param name="radius"></param>
    public void DrawCircle(int steps, float radius)
    {

        m_CircleRenderer.positionCount = steps;

        for(int currentStep = 0; currentStep < steps; currentStep++)
        {
            float l_circumferenceProgress = (float)currentStep / steps;

            float l_currentRadient = l_circumferenceProgress * 2 * Mathf.PI;

            float l_XScale = Mathf.Cos(l_currentRadient);
            float l_YScale = Mathf.Sin(l_currentRadient);

            float x = l_XScale * radius;
            float y = l_YScale * radius;

            Vector3 l_currentPos = new Vector3(x, y, 0);

            m_color = new Color(1f, 1f, 1f, m_alphaCircle);

            m_gradient = new Gradient();

            GradientColorKey[] gck = new GradientColorKey[2];
            GradientAlphaKey[] gak = new GradientAlphaKey[2];

            gck[0].color = m_color;
            gck[0].time = 0.0f;
            gck[1].color = m_color;
            gck[1].time = 1.0f;
            gak[0].alpha = m_alphaCircle;
            gak[0].time = 0.0f;
            gak[1].alpha = m_alphaCircle;
            gak[1].time = 1.0f;

            m_gradient.SetKeys(gck, gak);

            // canviar la alpha del material

            m_CircleRenderer.colorGradient = m_gradient;

            m_CircleRenderer.SetPosition(currentStep, l_currentPos);
            m_CircleRenderer.startWidth = 1f;
        }
    }

    /// <summary>
    /// set the health of the ui to a value
    /// </summary>
    /// <param name="health"></param>
    public void SetHealth(float health)
    {
        m_HealthBar.value = health;
    }
}
    