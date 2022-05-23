using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.InputSystem;

public class NewCameraController : MonoBehaviour
{
    private PlayerInput playerInput;
    private InputAction moveCamera;

    [SerializeField]
    private PauseMenu m_pauseMenu;

    [SerializeField]
    private GameObject m_normalCamera;

    [SerializeField]
    private GameObject m_aimCamera;

    [SerializeField]
    private Transform m_player;

    [Header("Camera")]
    [SerializeField]
    private float m_MaxPitchDistance = 320f;
    [SerializeField]
    private float m_MinPitchDistance = 60f;
    [SerializeField]
    [Range(0.1f, 1f)]
    private float m_mouseSensitivity;
    [SerializeField]
    [Range(0.1f, 1f)]
    private float m_gamepadSensitivity;

    public void SetIsAiming(bool l_isAiming)
    {
        if (l_isAiming)
        {
            m_normalCamera.SetActive(false);
            m_aimCamera.SetActive(true);
        }
        else
        {
            m_aimCamera.SetActive(false);
            m_normalCamera.SetActive(true);       
        }
    }

    void Start()
    {
        playerInput = GetComponent<PlayerInput>();
        moveCamera = playerInput.actions["Look"];
    }

    void Update()
    {
        if (!m_pauseMenu.GetPaused())
        {
            Vector2 input = moveCamera.ReadValue<Vector2>();

            string number = m_mouseSensitivity.ToString().Replace(",", ".");
            string path = "scaleVector2(x="+number+", y="+number+")";
            moveCamera.ApplyBindingOverride(0, new InputBinding {overrideProcessors = path });            
            string number2 = m_gamepadSensitivity.ToString().Replace(",", ".");
            string path2 = "scaleVector2(x="+number2+", y="+number2+")";
            moveCamera.ApplyBindingOverride(1, new InputBinding {overrideProcessors = path2 });

            float l_MouseDeltaX = input.x;
            float l_MouseDeltaY = input.y;

            transform.rotation *= Quaternion.AngleAxis(l_MouseDeltaX, Vector3.up);
            transform.rotation *= Quaternion.AngleAxis(-l_MouseDeltaY, Vector3.right);

            var angles = transform.localEulerAngles;
            angles.z = 0;

            var angle = transform.localEulerAngles.x;

            if (angle > 180 && angle < m_MaxPitchDistance)
            {
                angles.x = m_MaxPitchDistance;
            }
            else if (angle < 180 && angle > m_MinPitchDistance)
            {
                angles.x = m_MinPitchDistance;
            }

            transform.localEulerAngles = angles;

            m_player.rotation = Quaternion.Euler(0, transform.rotation.eulerAngles.y, 0);

            Vector3 l_Forward = transform.forward;
            l_Forward.y = 0.0f;
            m_player.forward = l_Forward;

            transform.localEulerAngles = new Vector3(angles.x, 0, 0);
        }    
    }
}
